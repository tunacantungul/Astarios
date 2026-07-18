extends PanelContainer
## Basit sıralı diyalog kutusu. Oyun durdurulmuşken de çalışır (process_mode: Always).
## Satırlar soldan sağa harf harf yazılır; SPACE / E / Enter yazımı tamamlar,
## satır tamamsa bir sonrakine geçer. Satırlar bitince finished sinyali yayar.
##
## Kritik satırlarda ekran sallanır. Hangi satırların sallayacağı, diyaloğu
## başlatan sahnenin (level.gd / epilogue.gd) "shake_lines" listesinden gelir.

signal finished

## Saniyede kaç harf yazılacağı.
@export var chars_per_second: float = 45.0
## Kritik satırlarda sarsıntının başlangıç şiddeti (piksel).
@export var shake_strength: float = 24.0
## Sarsıntının sönümlenerek biteceği süre (saniye).
@export var shake_duration: float = 0.5

var _lines: Array[String] = []
## _lines ile aynı indisli; true olan satır ekranı sallar.
var _shake_lines: Array[bool] = []
var _index: int = 0
var _typing: bool = false
## Kesirli ilerleme; int'e yuvarlanarak visible_characters'a yazılır.
var _revealed: float = 0.0
var _shake_left: float = 0.0
## Sarsıntıyı uyguladığımız düğüm: önce aktif Camera2D, yoksa üstteki CanvasLayer.
## Camera2D ile CanvasLayer'ın ortak atası "offset" taşımadığı için tipsiz tutuluyor.
var _shake_target = null
var _shake_base: Vector2 = Vector2.ZERO

@onready var name_label: Label = %NameLabel
@onready var text_label: Label = %TextLabel

func _ready() -> void:
	set_process(false)

func start(speaker: String, lines: Array[String], shake_lines: Array[bool] = []) -> void:
	if lines.is_empty():
		finished.emit()
		return
	_lines = lines
	_shake_lines = shake_lines
	_index = 0
	name_label.text = speaker
	visible = true
	set_process(true)
	_show_line()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not event.is_action_pressed("advance"):
		return
	get_viewport().set_input_as_handled()
	if _typing:
		# Yazım sürüyorsa önce satırı tamamla, geçmek için ikinci basış gerekir.
		_complete_line()
		return
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_show_line()

func _process(delta: float) -> void:
	if _typing:
		_revealed += chars_per_second * delta
		var total := text_label.get_total_character_count()
		text_label.visible_characters = int(_revealed)
		if int(_revealed) >= total:
			_complete_line()
	if _shake_left > 0.0:
		_update_shake(delta)

## --- Satır yazımı ---

func _show_line() -> void:
	text_label.text = _lines[_index]
	text_label.visible_characters = 0
	_revealed = 0.0
	_typing = true
	if _index < _shake_lines.size() and _shake_lines[_index]:
		_start_shake()

func _complete_line() -> void:
	_typing = false
	text_label.visible_characters = -1

func _close() -> void:
	_typing = false
	visible = false
	set_process(false)
	_stop_shake()
	finished.emit()

## --- Ekran sarsıntısı ---

func _start_shake() -> void:
	_stop_shake()
	_shake_target = get_viewport().get_camera_2d()
	if _shake_target == null:
		# Epilog gibi kamerasız sahnelerde her şey CanvasLayer üstünde duruyor.
		_shake_target = _find_canvas_layer()
	if _shake_target == null:
		return
	_shake_base = _shake_target.offset
	_shake_left = shake_duration

func _update_shake(delta: float) -> void:
	_shake_left = maxf(_shake_left - delta, 0.0)
	if _shake_target == null:
		return
	if _shake_left <= 0.0:
		_stop_shake()
		return
	# Şiddet süre boyunca doğrusal olarak sönümlenir.
	var amount := shake_strength * (_shake_left / shake_duration)
	_shake_target.offset = _shake_base + Vector2(
		randf_range(-amount, amount),
		randf_range(-amount, amount)
	)

func _stop_shake() -> void:
	if _shake_target != null:
		_shake_target.offset = _shake_base
		_shake_target = null
	_shake_left = 0.0

func _find_canvas_layer() -> CanvasLayer:
	var node: Node = get_parent()
	while node != null:
		if node is CanvasLayer:
			return node
		node = node.get_parent()
	return null
