class_name Player
extends CharacterBody2D
## Oyuncu: hareket, can, kalkan gücü ve hasar alma.

signal health_changed(current: float, max_value: float)
signal shield_state_changed(is_ready: bool)
signal died

@export var move_speed: float = 340.0
@export var max_health: float = 100.0
## Hasar aldıktan sonraki kısa dokunulmazlık süresi.
@export var invulnerability_time: float = 0.4
## Kalkanın bir vuruş blokladıktan sonra yeniden dolma süresi.
@export var shield_cooldown: float = 6.0

var health: float
var shield_ready: bool = false

var _invuln_left: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shield_visual: Sprite2D = $ShieldVisual
@onready var shield_timer: Timer = $ShieldTimer

func _ready() -> void:
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)
	shield_visual.visible = false
	if GameState.has_power(GameState.Power.SHIELD):
		shield_timer.wait_time = shield_cooldown
		shield_timer.start()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * move_speed
	move_and_slide()
	if _invuln_left > 0.0:
		_invuln_left -= delta

## Düşman temas hasarı. Kalkan hazırsa vuruşu bloklar.
func take_damage(amount: float) -> void:
	if health <= 0.0 or _invuln_left > 0.0:
		return
	_invuln_left = invulnerability_time
	if shield_ready:
		_consume_shield()
		return
	_flash()
	_apply_damage(amount)

## Tehlikeli zemin hasarı (bulut boşluğu, su). Kalkanı ve dokunulmazlığı yok sayar.
func take_hazard_damage(amount: float) -> void:
	if health <= 0.0:
		return
	_apply_damage(amount)

func _apply_damage(amount: float) -> void:
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		_die()

func _consume_shield() -> void:
	shield_ready = false
	shield_visual.visible = false
	shield_state_changed.emit(false)
	shield_timer.start()

func _flash() -> void:
	sprite.modulate = Color(1.0, 0.35, 0.35)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

func _die() -> void:
	died.emit()
	hide()
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	GameState.game_over.call_deferred()

func _on_shield_timer_timeout() -> void:
	if not GameState.has_power(GameState.Power.SHIELD):
		return
	shield_ready = true
	shield_visual.visible = true
	shield_state_changed.emit(true)
