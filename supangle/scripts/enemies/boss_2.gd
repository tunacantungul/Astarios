extends Boss
## Fırtına Habercisi (Bölüm 2 bossu): mesafesini korur ve oyuncuya 3'lü mermi yelpazesi atar.

@export var bolt_scene: PackedScene
@export var fire_cooldown: float = 2.6
## Yelpazedeki her mermi ayrı vurduğu için tek atışın toplamı bunun 3 katı.
@export var bolt_damage: float = 7.0
## Oyuncuyla korumaya çalıştığı mesafe.
@export var preferred_distance: float = 1700.0

## Uçuş hissi için gövdenin süzülürken yaptığı dikey salınım. Diğer canavarların
## sağa sola yalpalaması bir kuşta yanlış duruyordu; onun yerine yerinde hafifçe
## alçalıp yükseliyor. Gölge bu salınıma katılmıyor, yerde sabit kalıyor.
@export var hover_amount: float = 26.0
@export var hover_speed: float = 2.4

var _hover_time: float = randf() * TAU
var _sprite_base_y: float = 0.0

@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	super._ready()
	_sprite_base_y = sprite.position.y
	fire_timer.wait_time = fire_cooldown
	fire_timer.start()

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var to_player := _player.global_position - global_position
	var direction := to_player.normalized()
	if to_player.length() < preferred_distance:
		direction = -direction
	velocity = direction * move_speed * speed_multiplier()
	move_and_slide()
	# Bu sınıf _physics_process'i tamamen devraldığı için Enemy'nin bakış yönü
	# güncellemesi çalışmıyordu; boss hiç aynalanmıyordu.
	_update_facing()
	_animate_hover(delta)
	_tick_contact_damage(delta)

## Yerinde süzülme: yalnızca gövde sprite'ı oynuyor, gölge yerinde kalıyor.
func _animate_hover(delta: float) -> void:
	_hover_time += delta * hover_speed
	sprite.position.y = _sprite_base_y + sin(_hover_time) * hover_amount

func _on_fire_timer_timeout() -> void:
	if bolt_scene == null or _player == null or not is_instance_valid(_player):
		return
	var base_angle := (_player.global_position - global_position).angle()
	for offset in [-0.25, 0.0, 0.25]:
		var bolt: Node2D = bolt_scene.instantiate()
		bolt.position = global_position
		bolt.direction = Vector2.from_angle(base_angle + offset)
		bolt.damage = bolt_damage
		get_parent().add_child(bolt)
