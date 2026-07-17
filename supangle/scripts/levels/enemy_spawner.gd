extends Node2D
## Vampire Survivors tarzı spawner: oyuncunun etrafında, ekran dışında düşman doğurur.
## Zamanla spawn aralığı kısalır, tempo artar.

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 1.2
@export var min_spawn_interval: float = 0.35
## Her spawn sonrası aralığın ne kadar kısalacağı.
@export var interval_decay: float = 0.015
## Oyuncudan ne kadar uzakta doğacakları (ekran dışı olacak şekilde).
@export var spawn_distance: float = 950.0
## Düşmanların doğabileceği dünya alanı (duvarların içi).
@export var spawn_area: Rect2 = Rect2(-1550, -950, 3100, 1900)
@export var max_enemies: int = 120

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	_try_spawn()
	spawn_timer.wait_time = maxf(min_spawn_interval, spawn_timer.wait_time - interval_decay)
	spawn_timer.start()

func _try_spawn() -> void:
	if enemy_scenes.is_empty():
		return
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var pos := player.global_position + Vector2.from_angle(randf() * TAU) * spawn_distance
	pos.x = clampf(pos.x, spawn_area.position.x, spawn_area.end.x)
	pos.y = clampf(pos.y, spawn_area.position.y, spawn_area.end.y)
	var enemy: Node2D = enemy_scenes.pick_random().instantiate()
	enemy.position = pos
	get_parent().add_child(enemy)
