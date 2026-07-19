extends Node2D
## "freeze" kartı: Boreas'ın Soluğu: çevredeki düşmanları kısa süre dondurur.
## Kart seviyeleri: 1 = açılır (10 sn, 1.5 sn donma), 2 = 7 sn ve 2.5 sn donma,
## 3 = donma alanı büyür. Bosslar donmaya bağışıktır.

@export var base_interval: float = 10.0
@export var fast_interval: float = 7.0
@export var freeze_duration: float = 1.5
@export var long_freeze_duration: float = 2.5
@export var radius: float = 1000.0
@export var big_radius: float = 1450.0

## Halka görselindeki parıltının yarıçapı (piksel). Ring_glow.png'de daire
## 1024'lük tuvalin 968 pikselini dolduruyor; ölçek buna göre hesaplanınca
## görünen halkanın kenarı donma menziline oturuyor.
const RING_HALF_EXTENT := 484.0
## Halka mor çizildi; buzul mavisi olarak okunması için çarpılıyor.
const RING_COLOR := Color(0.64, 2.49, 1.48, 0.9)

@onready var ring: Sprite2D = $Ring
@onready var pulse_timer: Timer = $PulseTimer

func _ready() -> void:
	ring.visible = false
	GameState.upgrades_changed.connect(_refresh)
	GameState.powers_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var tier := GameState.upgrade_tier("freeze")
	if tier <= 0 or not GameState.has_power(GameState.Power.ATTACK):
		pulse_timer.stop()
		ring.visible = false
		return
	pulse_timer.wait_time = fast_interval if tier >= 2 else base_interval
	if pulse_timer.is_stopped():
		pulse_timer.start()

func _on_pulse_timer_timeout() -> void:
	var tier := GameState.upgrade_tier("freeze")
	var r := big_radius if tier >= 3 else radius
	var duration := long_freeze_duration if tier >= 2 else freeze_duration
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		if global_position.distance_to(enemy.global_position) <= r:
			enemy.freeze(duration)
	_flash(r)

## Kısa buz mavisi halka parlaması; görsel yarıçapa ölçeklenir.
## Halka görseli zaten mavi çizildi, bu yüzden renk bozulmasın diye
## modulate nötr tutuluyor.
func _flash(r: float) -> void:
	ring.scale = Vector2.ONE * (r / RING_HALF_EXTENT)
	ring.modulate = RING_COLOR
	ring.visible = true
	var tween := create_tween()
	tween.tween_property(ring, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void: ring.visible = false)
