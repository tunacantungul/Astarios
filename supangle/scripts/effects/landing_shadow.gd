extends Node2D
## Uçuş sırasında karakterin ayağının altında beliren yuvarlak gölge: süre
## dolunca nereye ineceğini gösterir. Sanatçıdan gölge görseli beklemeden
## çalışsın diye elle çiziliyor.

## Gölgenin yatay yarıçapı. Dikey yarıçap bunun ratio katı; yerde yatan bir
## elips izlenimi veriyor.
@export var radius: float = 78.0
@export var flatten: float = 0.42
@export var fill_color: Color = Color(0.0, 0.0, 0.0, 0.38)
@export var edge_color: Color = Color(0.0, 0.0, 0.0, 0.55)
## Elipsi kaç parçaya bölerek çizeceğimiz.
const SEGMENTS := 32

func _draw() -> void:
	var points := PackedVector2Array()
	for i in SEGMENTS:
		var angle := TAU * i / SEGMENTS
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius * flatten))
	draw_colored_polygon(points, fill_color)
	# Kenar çizgisi gölgeyi zeminden ayırıyor; kapanması için ilk nokta eklenir.
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, edge_color, 3.0, true)
