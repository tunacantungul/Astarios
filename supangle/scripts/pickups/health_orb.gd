extends Node2D
## Bazı düşmanlardan düşük şansla düşen can küresi; dokununca iyileştirir.
## XP taşının aksine uzaktan çekilmez (magnet kartından etkilenmez).

@export var heal_amount: float = 15.0
@export var collect_radius: float = 150.0

var _player: Player

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player

func _physics_process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player) or _player.health <= 0.0:
		return
	# Havadayken yerdekiler toplanmaz.
	if _player.is_flying:
		return
	if global_position.distance_to(_player.global_position) <= collect_radius:
		_player.heal(heal_amount)
		queue_free()
