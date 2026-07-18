extends Node2D
## Vampire Survivors tarzı spawner: oyuncunun etrafında, ekran dışında düşman doğurur.
## Zamanla spawn aralığı kısalır, tempo artar.

@export var enemy_scenes: Array[PackedScene] = []
## enemy_scenes ile aynı sıradaki doğma ağırlıkları. Boş bırakılırsa hepsi
## eşit olasılıkla doğar. Zor düşmanların sayısını kısmak için kullanılıyor.
@export var spawn_weights: Array[float] = []
@export var spawn_interval: float = 1.2
@export var min_spawn_interval: float = 0.28
## Her spawn sonrası aralığın ne kadar kısalacağı. Bölüm ilerledikçe
## tempo bununla artıyor; min_spawn_interval tabanına kadar iniyor.
@export var interval_decay: float = 0.022
## Oyuncudan ne kadar uzakta doğacakları (ekran dışı olacak şekilde).
@export var spawn_distance: float = 4300.0
## Düşmanların doğabileceği dünya alanı (duvarların içi).
@export var spawn_area: Rect2 = Rect2(-7000, -4300, 14000, 8600)
@export var max_enemies: int = 150

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
	var enemy: Node2D = _pick_scene().instantiate()
	enemy.position = pos
	get_parent().add_child(enemy)

## Ağırlıklar verilmişse onlara göre, verilmemişse eşit olasılıkla seçer.
func _pick_scene() -> PackedScene:
	if spawn_weights.size() != enemy_scenes.size():
		return enemy_scenes.pick_random()
	var total := 0.0
	for weight in spawn_weights:
		total += weight
	if total <= 0.0:
		return enemy_scenes.pick_random()
	var roll := randf() * total
	for i in enemy_scenes.size():
		roll -= spawn_weights[i]
		if roll <= 0.0:
			return enemy_scenes[i]
	return enemy_scenes[enemy_scenes.size() - 1]
