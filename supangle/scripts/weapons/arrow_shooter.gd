extends Node2D
## "artemis" kartı: Artemis'in Oku — en yakın düşmana doğru, hattaki tüm
## düşmanları delip geçen ok fırlatır. Başlangıçta kapalıdır.
## Kart seviyeleri: 1 = açılır (6 sn), 2 = hızlanır (4 sn), 3 = hasar iki katı.

@export var arrow_scene: PackedScene
@export var base_interval: float = 6.0
@export var fast_interval: float = 4.0
@export var arrow_damage: float = 25.0
@export var attack_range: float = 3400.0

@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	GameState.upgrades_changed.connect(_refresh)
	GameState.powers_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var tier := GameState.upgrade_tier("artemis")
	if tier <= 0 or not GameState.has_power(GameState.Power.ATTACK):
		fire_timer.stop()
		return
	fire_timer.wait_time = fast_interval if tier >= 2 else base_interval
	if fire_timer.is_stopped():
		fire_timer.start()

func _on_fire_timer_timeout() -> void:
	var target := _nearest_enemy()
	if target == null:
		return
	var tier := GameState.upgrade_tier("artemis")
	var arrow: ArtemisArrow = arrow_scene.instantiate()
	arrow.position = global_position
	arrow.direction = (target.global_position - global_position).normalized()
	arrow.damage = arrow_damage * (2.0 if tier >= 3 else 1.0)
	get_tree().current_scene.add_child(arrow)

func _nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var best := attack_range * attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		if enemy == null:
			continue
		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < best:
			best = dist
			nearest = enemy
	return nearest
