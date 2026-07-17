class_name Player
extends CharacterBody2D
## Oyuncu: hareket, can ve hasar alma.
## Ölümsüzlük gücü varken hiçbir hasar işlemez ve karakter altın bir aura ile parlar.

signal health_changed(current: float, max_value: float)
signal died

@export var move_speed: float = 340.0
@export var max_health: float = 100.0
## Hasar aldıktan sonraki kısa dokunulmazlık süresi.
@export var invulnerability_time: float = 0.4

var health: float

var _invuln_left: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var divine_aura: Sprite2D = $DivineAura

func _ready() -> void:
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)
	divine_aura.visible = GameState.has_power(GameState.Power.IMMORTALITY)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * move_speed
	move_and_slide()
	if _invuln_left > 0.0:
		_invuln_left -= delta

## Düşman temas hasarı.
func take_damage(amount: float) -> void:
	if health <= 0.0 or _invuln_left > 0.0:
		return
	if GameState.has_power(GameState.Power.IMMORTALITY):
		return
	_invuln_left = invulnerability_time
	_flash()
	_apply_damage(amount)

## Tehlikeli zemin hasarı (bulut boşluğu, su). Dokunulmazlık süresini yok sayar.
func take_hazard_damage(amount: float) -> void:
	if health <= 0.0:
		return
	if GameState.has_power(GameState.Power.IMMORTALITY):
		return
	_apply_damage(amount)

func _apply_damage(amount: float) -> void:
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		_die()

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
