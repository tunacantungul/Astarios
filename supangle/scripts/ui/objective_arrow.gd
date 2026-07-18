extends Control
## Ekranın üstünde duran, hedefe doğru dönen yön oku (pusula gibi).
## Boss arenası açılınca arenayı, boss ölünce çıkış kapısını gösterir.
## Dünya koordinatlarında değil ekranda sabit durur; sadece yönü döner,
## böylece hedef ekran dışındayken de nereye gidileceği belli olur.

## Ok yukarıyı (-Y) gösterecek şekilde, merkezi orijinde çizildi.
## arrow_size ile ölçeklenir. PackedVector2Array sabit ifade olamadığı için
## düz dizi tutulup çizim sırasında paketleniyor.
const SHAPE: Array[Vector2] = [
	Vector2(0.0, -1.0),
	Vector2(0.72, -0.1),
	Vector2(0.3, -0.1),
	Vector2(0.3, 0.85),
	Vector2(-0.3, 0.85),
	Vector2(-0.3, -0.1),
	Vector2(-0.72, -0.1),
]

@export var arrow_color: Color = Color(1.0, 0.85, 0.25)
@export var outline_color: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var outline_width: float = 7.0
## Okun yarı yüksekliği (piksel). Uzaktan görünecek kadar büyük.
@export var arrow_size: float = 48.0
## Okun gösterdiği yönde hafifçe ileri geri süzülmesi.
@export var bob_amount: float = 8.0
@export var bob_speed: float = 3.5

var _target: Node2D
var _player: Node2D
var _time: float = 0.0

func _ready() -> void:
	visible = false
	set_process(false)

## Oku verilen düğüme yöneltir ve gösterir.
func point_to(target: Node2D, color: Color) -> void:
	_target = target
	arrow_color = color
	visible = true
	set_process(true)
	queue_redraw()

func clear_target() -> void:
	_target = null
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		clear_target()
		return
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	# Şekil yukarıyı gösterdiği için açıya çeyrek tur eklenir.
	rotation = (_target.global_position - _player.global_position).angle() + PI * 0.5
	_time += delta
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5 + Vector2(0.0, -absf(sin(_time * bob_speed)) * bob_amount)
	var points := PackedVector2Array()
	for point in SHAPE:
		points.append(center + point * arrow_size)
	# Önce kalın siyah kenarlık, sonra üstüne dolgu: her zeminde okunur kalsın.
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, outline_color, outline_width, true)
	draw_colored_polygon(points, arrow_color)
