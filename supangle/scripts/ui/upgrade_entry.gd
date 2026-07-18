extends PanelContainer
## Tek bir alınmış güç kutucuğu: ikon + "Ad  Sv N".
## HUD'un sol panelinde ve kart menüsünün üst satırında kullanılır.
## Önce ağaca ekleyin, sonra setup() çağırın.

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel

func setup(icon_texture: Texture2D, text: String) -> void:
	icon.texture = icon_texture
	name_label.text = text
