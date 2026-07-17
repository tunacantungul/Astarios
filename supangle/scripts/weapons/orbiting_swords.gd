extends Node2D
## Oyuncunun etrafında dönen kılıçlar; temas eden düşmanlara periyodik hasar verir.
## Kılıçlar bu sahnenin Area2D çocuklarıdır, sayısı/dizilimi sahneden düzenlenebilir.

@export var rotation_speed: float = 2.6
@export var damage: float = 15.0
## Aynı düşmana iki vuruş arası minimum süre.
@export var hit_cooldown: float = 0.4

var _last_hit_at: Dictionary = {}

func _ready() -> void:
	if not GameState.has_power(GameState.Power.ATTACK):
		visible = false
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	rotation += rotation_speed * delta
	var now := Time.get_ticks_msec() / 1000.0
	for sword in get_children():
		var area := sword as Area2D
		if area == null:
			continue
		for body in area.get_overlapping_bodies():
			var enemy := body as Enemy
			if enemy == null:
				continue
			var id := enemy.get_instance_id()
			if now - float(_last_hit_at.get(id, -1000.0)) >= hit_cooldown:
				_last_hit_at[id] = now
				enemy.take_damage(damage)
	if _last_hit_at.size() > 512:
		_last_hit_at.clear()
