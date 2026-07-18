extends Node2D
## "nova" kartı (Bölüm 2+): Zeus'un yıldırımlarına oyuncunun cevabı.
## Periyodik olarak oyuncunun çevresindeki düşmanlara yıldırım şoku verir.
## Kart seviyeleri: 1 = açılır (6 sn), 2 = sıklık artar (4 sn), 3 = hasar ve alan büyür.

@export var damage: float = 25.0
@export var base_interval: float = 6.0
@export var fast_interval: float = 4.0
@export var radius: float = 720.0
@export var big_radius: float = 950.0
## 3. seviyede hasar çarpanı.
@export var strong_multiplier: float = 1.6

@onready var ring: Sprite2D = $Ring
@onready var pulse_timer: Timer = $PulseTimer

func _ready() -> void:
	ring.visible = false
	GameState.upgrades_changed.connect(_refresh)
	GameState.powers_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var tier := GameState.upgrade_tier("nova")
	if tier <= 0 or not GameState.has_power(GameState.Power.ATTACK):
		pulse_timer.stop()
		ring.visible = false
		return
	pulse_timer.wait_time = fast_interval if tier >= 2 else base_interval
	if pulse_timer.is_stopped():
		pulse_timer.start()

func _on_pulse_timer_timeout() -> void:
	var tier := GameState.upgrade_tier("nova")
	var r := big_radius if tier >= 3 else radius
	var dmg := damage * (strong_multiplier if tier >= 3 else 1.0)
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		if global_position.distance_to(enemy.global_position) <= r:
			enemy.take_damage(dmg)
	_flash(r)

## Kısa altın halka parlaması; telegraph görseli yarıçapa ölçeklenir.
func _flash(r: float) -> void:
	ring.scale = Vector2.ONE * (r / 108.0)
	ring.modulate = Color(1.6, 1.5, 0.7, 0.9)
	ring.visible = true
	var tween := create_tween()
	tween.tween_property(ring, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void: ring.visible = false)
