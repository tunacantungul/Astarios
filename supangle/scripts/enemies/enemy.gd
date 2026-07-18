class_name Enemy
extends CharacterBody2D
## Oyuncuya doğru yürüyen ve temasta hasar veren düşman.
## Tüm düşman tipleri bu scripti kullanır; farklar export değerlerinden gelir.
## Ölünce XP taşı, düşük şansla da can küresi düşürür.

const XP_GEM_SCENE := preload("res://scenes/pickups/xp_gem.tscn")
const HEALTH_ORB_SCENE := preload("res://scenes/pickups/health_orb.tscn")
## Donmuş düşmanın rengi (Boreas'ın Soluğu).
const FROZEN_MODULATE := Color(0.55, 0.75, 1.0)
## "kronos" kartı: kademe başına kalıcı yavaşlama oranı.
const KRONOS_SLOW_PER_TIER := 0.12

@export var move_speed: float = 540.0
@export var max_health: float = 30.0
@export var contact_damage: float = 10.0
## Oyuncuyla temas hâlindeyken iki hasar arası süre.
@export var damage_interval: float = 0.8
## Ölünce düşen XP taşının değeri.
@export var xp_value: int = 1
## Can küresi düşürme ihtimali (0-1).
@export var health_drop_chance: float = 0.06

var health: float

var _player: Player
var _damage_cooldown: float = 0.0
var _frozen_left: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var damage_area: Area2D = $DamageArea

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_player = get_tree().get_first_node_in_group("player") as Player

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	if _tick_frozen(delta):
		return
	var direction := (_player.global_position - global_position).normalized()
	velocity = direction * move_speed * speed_multiplier()
	move_and_slide()
	_tick_contact_damage(delta)

## "kronos" kartı (Kronos'un Kumu): tüm düşmanlar kademe başına kalıcı yavaşlar.
## Donmanın aksine bosslar da etkilenir.
func speed_multiplier() -> float:
	return 1.0 - KRONOS_SLOW_PER_TIER * GameState.upgrade_tier("kronos")

## Donma sayacı: donmuşken hareket de temas hasarı da yok. true = donmuş.
func _tick_frozen(delta: float) -> bool:
	if _frozen_left <= 0.0:
		return false
	_frozen_left -= delta
	if _frozen_left <= 0.0:
		sprite.modulate = Color.WHITE
	return true

## Boreas'ın Soluğu: düşmanı kısa süreliğine dondurur. Bosslar bunu ezer.
func freeze(duration: float) -> void:
	_frozen_left = maxf(_frozen_left, duration)
	sprite.modulate = FROZEN_MODULATE

## Temas hasarı sayacı; boss alt sınıfları da hareketten bağımsız kullanır.
func _tick_contact_damage(delta: float) -> void:
	_damage_cooldown -= delta
	if _damage_cooldown <= 0.0 and damage_area.overlaps_body(_player):
		_player.take_damage(contact_damage)
		_damage_cooldown = damage_interval

func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health -= amount
	_flash()
	if health <= 0.0:
		_die()

func _flash() -> void:
	sprite.modulate = Color(1.8, 1.8, 1.8)
	var target := FROZEN_MODULATE if _frozen_left > 0.0 else Color.WHITE
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", target, 0.15)

func _die() -> void:
	GameState.register_kill()
	_spawn_drops()
	queue_free()

## XP taşı (her zaman) ve şansa bağlı can küresi bırakır.
func _spawn_drops() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var gem: Node2D = XP_GEM_SCENE.instantiate()
	gem.xp_value = xp_value
	gem.position = position
	parent.add_child.call_deferred(gem)
	if randf() < health_drop_chance:
		var orb: Node2D = HEALTH_ORB_SCENE.instantiate()
		orb.position = position + Vector2(randf_range(-110.0, 110.0), randf_range(-110.0, 110.0))
		parent.add_child.call_deferred(orb)
