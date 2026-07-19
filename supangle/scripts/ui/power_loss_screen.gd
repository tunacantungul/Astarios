extends Control
## Bölüm sonu diyaloğundan sonra gelen siyah ekran: kaybedilen gücü yazar.
## Transition autoload'u tarafından yönetilir; kararma ile açılma arasında
## sahne değişimi yapılabilsin diye iki aşama ayrı ayrı beklenebiliyor.
## Oyun ağacı o sırada duraklatılmış olabildiği için process_mode: Always.

@export var fade_in: float = 0.8
@export var hold: float = 1.8
@export var fade_out: float = 0.8

@onready var label: Label = %Label

func _ready() -> void:
	modulate.a = 0.0

## Ekranı karartıp yazıyı gösterir; yazı okunacak kadar bekledikten sonra döner.
## Örnek: "Ölümsüzlüğünü kaybettin..."
## `fade_time` ve `hold_time` verilmezse dışa açık varsayılanlar kullanılır;
## yazısız sade geçişte ikisi de kısaltılıyor, orada okunacak bir şey yok.
func fade_to_black(text: String, fade_time: float = -1.0, hold_time: float = -1.0) -> void:
	label.text = text
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in if fade_time < 0.0 else fade_time)
	tween.tween_interval(hold if hold_time < 0.0 else hold_time)
	await tween.finished

## Karanlığı açar; arkadaki yeni bölüm ortaya çıkar.
func reveal() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_out)
	await tween.finished
