extends Node2D
## Karakterin başının üstünde durup hedefe (boss arenası / kapı) dönen yön oku.
##
## Karakterin ÇOCUĞU olarak dünyada duruyor, ekran (HUD) ögesi değil. Sebep:
## fizik enterpolasyonu açık ve kamera yumuşatmalı; oku HUD'da tutup her karede
## kamera dönüşümüyle elle konumlandırınca render'ın kullandığı enterpolasyonlu
## değerle uyuşmuyor ve Windows'ta yüksek yenileme hızında takılıyordu. Çocuk
## olarak konumu sabit; motor karakterle birlikte onu da enterpolasyonla
## yumuşatıyor. Yön ve süzülme yalnızca _draw içinde (görsel), transform hiç
## değişmiyor — bu yüzden takılma olmuyor.

## Ok yukarıyı (-Y) gösterecek şekilde, merkezi orijinde çizildi.
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
## Dünya uzayında çizildiği ve kamera 0.5 yakınlaştırdığı için değerler eski
## ekran-uzayı hâlinin ~2 katı: ekranda aynı boyutta görünsün.
@export var outline_width: float = 14.0
@export var arrow_size: float = 96.0
## Okun gösterdiği yönde hafifçe ileri geri süzülmesi. Artık her zaman açık:
## dünya çocuğu olduğu için hareket hâlinde de takılmadan akıyor.
@export var bob_amount: float = 16.0
@export var bob_speed: float = 3.5

var _target: Node2D
var _time: float = 0.0

func _ready() -> void:
	add_to_group("objective_arrow")
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
	_time += delta
	queue_redraw()

## Hedefin tam ortası. Düğüm orijini yerine çarpışma şeklinin global konumu
## kullanılıyor: arena çemberi ve kapı büyük alanlar, şekil düğüme göre kayarsa
## ok kenarı gösterip oyuncuyu yanlış noktaya yollardı.
func _target_center() -> Vector2:
	var shape := _target.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape != null:
		return shape.global_position
	return _target.global_position

func _draw() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	# Yön ve süzülme yalnızca çizimde: düğümün transformu değişmiyor, böylece
	# karakterin enterpolasyonlu hareketiyle birebir akıyor.
	var dir := (_target_center() - global_position).angle() + PI * 0.5
	var bob := Vector2(0.0, -absf(sin(_time * bob_speed)) * bob_amount)
	var points := PackedVector2Array()
	for point in SHAPE:
		points.append((point * arrow_size + bob).rotated(dir))
	# Önce kalın siyah kenarlık, sonra üstüne dolgu: her zeminde okunur kalsın.
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, outline_color, outline_width, true)
	draw_colored_polygon(points, arrow_color)
