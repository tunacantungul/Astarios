extends Control
## Bölüm sonu diyaloğundan sonra gelen siyah ekran: kaybedilen gücü yazar.
## Oyun ağacı o sırada duraklatılmış olduğu için process_mode: Always.
## Yazı belirir, kısa süre kalır, kararır ve finished sinyali yayılır.

signal finished

@export var fade_in: float = 0.8
@export var hold: float = 1.8
@export var fade_out: float = 0.8

@onready var label: Label = %Label

func _ready() -> void:
	modulate.a = 0.0

## Örnek: "Ölümsüzlüğünü kaybettin..."
func show_loss(text: String) -> void:
	label.text = text
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in)
	tween.tween_interval(hold)
	tween.tween_property(self, "modulate:a", 0.0, fade_out)
	tween.tween_callback(func() -> void: finished.emit())
