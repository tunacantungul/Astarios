extends Node2D
## Düşmanlardan düşen XP taşı (Vampire Survivors tarzı).
## Oyuncu çekim menziline girince taşa doğru uçar, temas menzilinde toplanır.
## "magnet" kartı (Kehribar Tılsımı) çekim menzilini büyütür.

@export var xp_value: int = 1
@export var base_magnet_radius: float = 360.0
@export var collect_radius: float = 135.0
@export var fly_speed: float = 2200.0

## "magnet" kartı kademelerine göre çekim menzili çarpanı (0 = kart yok).
const MAGNET_MULT := [1.0, 1.1, 2.0]

## Taşın rengi XP değerinden geliyor ve düşürdüğü canavarın rengiyle eşleşiyor:
## temel canavar mavi, turuncu hızlı canavar turuncu, mor tank mor taş bırakır.
## Böylece yerdeki taşın ne kadar değerli olduğu uzaktan okunuyor.
## Taş görseli mavi çizildi; modulate çarpma yaptığı için renkleri bu
## katsayılarla elde ediyoruz. Liste büyük değerden küçüğe taranır.
const GEM_TIERS: Array = [
	{"min_xp": 5, "modulate": Color(2.1, 0.5, 1.15)},
	{"min_xp": 2, "modulate": Color(3.0, 0.85, 0.2)},
]

var _player: Player

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	for tier: Dictionary in GEM_TIERS:
		if xp_value >= tier["min_xp"]:
			sprite.modulate = tier["modulate"]
			break

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player) or _player.health <= 0.0:
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist <= collect_radius:
		GameState.gain_xp(xp_value)
		queue_free()
		return
	var tier := mini(GameState.upgrade_tier("magnet"), MAGNET_MULT.size() - 1)
	if dist <= base_magnet_radius * MAGNET_MULT[tier]:
		global_position = global_position.move_toward(_player.global_position, fly_speed * delta)
