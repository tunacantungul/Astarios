class_name ArtemisArrow
extends Area2D
## Artemis'in Oku: düz bir hat boyunca uçar ve önüne çıkan her düşmanı
## delip geçerek vurur. Duvarlarda durmaz; süresi dolunca kaybolur.

var direction := Vector2.RIGHT
var damage := 25.0

## Okun gidişi gözle takip edilebilsin diye bilinçli olarak yavaş.
@export var speed: float = 2300.0

## Aynı okun aynı düşmana bir kez vurması için.
var _hit: Dictionary = {}

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	var enemy := body as Enemy
	if enemy == null:
		return
	var id := enemy.get_instance_id()
	if _hit.has(id):
		return
	_hit[id] = true
	enemy.take_damage(damage)

func _on_life_timer_timeout() -> void:
	queue_free()
