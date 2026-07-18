extends Node2D
## Kavuşma sahnesi: Olympus'tan ayrıldıktan sonra sevgiliyle buluşma.
## Sadece diyalogdan oluşur; diyalog bitince oyun zaferle sonlanır.

@export var speaker_name: String = "Kavuşma"
@export var dialogue_lines: Array[String] = []
## dialogue_lines ile aynı sırada işaret kutuları: işaretli satırda ekran sallanır.
@export var shake_lines: Array[bool] = []

@onready var dialogue_box: PanelContainer = $UI/DialogueBox

func _ready() -> void:
	dialogue_box.finished.connect(_on_dialogue_finished)
	dialogue_box.start(speaker_name, dialogue_lines, shake_lines)

func _on_dialogue_finished() -> void:
	GameState.finish_game()
