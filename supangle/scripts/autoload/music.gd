extends Node
## Oyunun müziği. Autoload olduğu için sahne değişiminde kesilmez.
##
## Ana tema bölümler boyunca tek parça olarak akar: bölüm değişiminde, diyalogda
## ya da kart menüsünde baştan başlamaz, yalnızca duraklatılıp kaldığı yerden
## devam eder. Bunun için her parçanın kendi oynatıcısı var; `stream_paused`
## çalma konumunu koruduğu için devam ederken `play()` çağırmıyoruz.

const MAIN_THEME := preload("res://assets/Sound/Main_theme.wav")
const EPILOGUE := preload("res://assets/Sound/Epilogue_music.mp3")

## Müzik efektlerin altında kalsın diye kısık.
const MAIN_VOLUME_DB := -14.0
const EPILOGUE_VOLUME_DB := -12.0

var _main: AudioStreamPlayer
var _epilogue: AudioStreamPlayer

func _ready() -> void:
	# Kart menüsü, diyalog ve bölüm geçişi ağacı duraklatıyor; müzik akmalı.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Döngü kurulumu içeriden yapılıyor: içe aktarma ayarlarına dokunmadan
	# her iki parçanın da kesintisiz tekrarlanmasını garanti ediyor.
	_loop(MAIN_THEME)
	_loop(EPILOGUE)
	_main = _make_player(MAIN_THEME, MAIN_VOLUME_DB)
	_epilogue = _make_player(EPILOGUE, EPILOGUE_VOLUME_DB)

## Bölümlerin müziği. Zaten çalıyorsa hiçbir şey yapmaz.
func play_main() -> void:
	_pause(_epilogue)
	_resume(_main)

## Kavuşma sahnesinin müziği.
func play_epilogue() -> void:
	_pause(_main)
	_resume(_epilogue)

## Menülerde sessizlik; ana tema kaldığı yerde bekler.
func pause_all() -> void:
	_pause(_main)
	_pause(_epilogue)

func _make_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player

## Duraklamışsa kaldığı yerden, hiç başlamamışsa baştan çalar.
func _resume(player: AudioStreamPlayer) -> void:
	player.stream_paused = false
	if not player.playing:
		player.play()

func _pause(player: AudioStreamPlayer) -> void:
	player.stream_paused = true

func _loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		stream.loop_begin = 0
		# loop_end örnek (sample) cinsinden; 0 bırakılırsa döngü boşa düşüyor.
		# Süreden hesaplamak sıkıştırma formatından bağımsız olarak doğru.
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamMP3:
		stream.loop = true
