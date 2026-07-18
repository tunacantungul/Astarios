extends Control
## Seviye atlama kart menüsü. Oyun durdurulmuşken çalışır (process_mode: Always).
## Level scripti open() ile açar; oyuncu kart seçince card_chosen sinyali yayılır.
## Üstte o ana kadar alınmış güçler ikon + seviye olarak listelenir.

signal card_chosen(id: String)

const UPGRADE_ENTRY_SCENE := preload("res://scenes/ui/upgrade_entry.tscn")

var _option_ids: Array[String] = []

@onready var _buttons: Array[Button] = [%Card1, %Card2, %Card3]
@onready var _owned_label: Label = %OwnedLabel
@onready var _owned_box: HBoxContainer = %OwnedBox

func _ready() -> void:
	visible = false
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_card_pressed.bind(i))

## Kart kimliklerini alır, başlık/açıklamaları havuzdan doldurur ve menüyü gösterir.
func open(options: Array[String]) -> void:
	_option_ids = options
	for i in _buttons.size():
		var has_option := i < options.size()
		_buttons[i].visible = has_option
		if has_option:
			var info: Dictionary = GameState.upgrade_card_info(options[i])
			_buttons[i].text = "%s\n\n%s" % [info.title, info.desc]
			_buttons[i].icon = GameState.upgrade_icon(options[i])
	_refresh_owned()
	visible = true

## Üst satır: şu ana kadar alınan güçler (ikon + Sv).
func _refresh_owned() -> void:
	for child in _owned_box.get_children():
		child.queue_free()
	var any := false
	for id: String in GameState.upgrades:
		var tier: int = GameState.upgrades[id]
		if tier <= 0:
			continue
		any = true
		var entry: PanelContainer = UPGRADE_ENTRY_SCENE.instantiate()
		_owned_box.add_child(entry)
		entry.setup(GameState.upgrade_icon(id), "%s  Sv %d" % [GameState.upgrade_name(id), tier])
	_owned_label.visible = any

func _on_card_pressed(index: int) -> void:
	visible = false
	card_chosen.emit(_option_ids[index])
