extends Node2D
## Menzildeki en yakın düşmana otomatik büyü mermisi fırlatır.

@export var bolt_scene: PackedScene
@export var fire_interval: float = 0.9
@export var bolt_damage: float = 20.0
@export var attack_range: float = 750.0

@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	if not GameState.has_power(GameState.Power.ATTACK):
		return
	fire_timer.wait_time = fire_interval
	fire_timer.start()

func _on_fire_timer_timeout() -> void:
	var target := _nearest_enemy()
	if target == null:
		return
	var bolt: Bolt = bolt_scene.instantiate()
	bolt.position = global_position
	bolt.direction = (target.global_position - global_position).normalized()
	bolt.damage = bolt_damage
	get_tree().current_scene.add_child(bolt)

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
