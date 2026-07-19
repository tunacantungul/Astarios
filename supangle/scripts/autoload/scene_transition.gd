extends CanvasLayer
## Bölümler arası siyah geçiş. Autoload olduğu için sahne değişiminden
## etkilenmez: ekran tamamen siyahken sahne değiştirilir, karanlık ancak yeni
## bölüm çizime hazır olduğunda açılır. Böylece geçiş sırasında biten bölüm
## bir kare bile yeniden görünmez.

const POWER_LOSS_SCENE := preload("res://scenes/ui/power_loss_screen.tscn")

var _screen: Control

func _ready() -> void:
	# Ağaç duraklatılmış olsa da geçiş animasyonu akmalı.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Bölüm içi UI'ların (HUD, kart menüsü) üstünde kalsın.
	layer = 128
	_screen = POWER_LOSS_SCENE.instantiate()
	add_child(_screen)
	_screen.hide()

## Kaybedilen gücü siyah ekranda yazar. Ekran tamamen siyahken `on_black`
## çağrılır; sahne değişimi orada yapılır.
func play_power_loss(text: String, on_black: Callable) -> void:
	_screen.show()
	await _screen.fade_to_black(text)
	on_black.call()
	# change_scene_to_file kare sonunda işleniyor. Yeni bölümün _ready'si çalışıp
	# ilk karesi hazırlanana kadar perdeyi kapalı tutuyoruz.
	await get_tree().process_frame
	await get_tree().process_frame
	await _screen.reveal()
	_screen.hide()

## Yazısız hızlı geçiş: ekranı karartır, sahneyi değiştirir, açar.
## Bölüm sahneleri elle çizilmiş harita yüzünden yüzlerce MB doku yüklüyor ve
## change_scene_to_file bu sırada donuyor. Perde olmadan oyuncu eski sahneye
## bakarken saniyelerce takılı kalıyor ve oyun kilitlenmiş sanıyordu.
func change_scene_covered(path: String) -> void:
	_screen.show()
	# Okunacak yazı yok: kısa karartma, beklemesiz.
	await _screen.fade_to_black("", 0.3, 0.0)
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	await _screen.reveal()
	_screen.hide()
