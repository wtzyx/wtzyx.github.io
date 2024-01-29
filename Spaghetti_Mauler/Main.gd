extends Node2D

@export var mob_scene: PackedScene
@export var cereal_scene: PackedScene

const DIF_EASY = 10
const DIF_MEDIUM = 5
const DIF_HARD = 1 #number of misses before you lose each difficulty
const DIF_EXTREME = 1
const DIF_MOD_EASY = 1
const DIF_MOD_MEDIUM = 2 # modifiers to difficulty, random speed 100 / mod, 100 * mod
const DIF_MOD_HARD = 3   # also affects mob spawn rate, random(2/mod, 2) seconds between spawns
const DIF_MOD_EXTREME = 4
const MUSIC_ENABLED = true
const SFX_ENABLED = true
const DEFAULT_SPRITE = "Torler Kurnz"
const DEFAULT_DIFFICULTY = "EASY"

var score
var num_missed # track number missed, higher difficultys/levels can miss less?
var SCREEN_WIDTH
var SCREEN_HEIGHT
var player_sprite = DEFAULT_SPRITE
var player_difficulty = DEFAULT_DIFFICULTY
var music_enabled = MUSIC_ENABLED
var sfx_enabled = SFX_ENABLED
var SPRITE_LIST = {}
var DIFFICULTY_LIST = {}
var mode = "spaghetti"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	SCREEN_WIDTH = $Player.get_screen_width()
	SCREEN_HEIGHT = $Player.get_screen_height()
	
	for i in $HUD/Options/optSprite.get_item_count():
		SPRITE_LIST[$HUD/Options/optSprite.get_item_id(i)] = $HUD/Options/optSprite.get_item_text(i)
	for i in $HUD/Options/optSprite/optDifficulty.get_item_count():
		DIFFICULTY_LIST[$HUD/Options/optSprite/optDifficulty.get_item_id(i)] = $HUD/Options/optSprite/optDifficulty.get_item_text(i)
	
	$HUD/Options.hide()
	$MusicPlayer.stream = load("res://sounds/spaghetti_menu.ogg")
	$MusicPlayer.play()
	$HUD/btnOptions.hide()
	$HUD/btnCereal.hide()
	$HUD/StartButton.hide()
	$HUD/ScoreLabel.hide()
	$HUD.show_message("Never forgetti......")
	await get_tree().create_timer(4).timeout
	$HUD/btnOptions.show()
	$HUD/StartButton.show()
	$HUD/btnCereal.show()
	$HUD/MessageLabel.text = "MAUL THAT SPAGHETT BOI!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#sets up a new game
func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	num_missed = 0
	$HUD/ScoreLabel.show()
	$HUD.update_score(score)
	if mode == "spaghetti":
		$HUD.show_message("It's MAULIN time!")
	elif mode == "cereal":
		$HUD.show_message("KILL that cereal!")
	
	$Player.start(player_sprite)
	$MusicPlayer.stop()
	$StartTimer.start()

#handles game loss
func game_over():
	$MobTimer.stop()
	get_tree().call_group("mobs", "queue_free")
	num_missed = 0
	$Player.game_over()
	$MusicPlayer.stop()
	$HUD.show_game_over(score)
	await get_tree().create_timer(1).timeout
	if mode == "spaghetti":
		$MusicPlayer.stream = load("res://sounds/spaghetti_menu.ogg")
	elif mode == "cereal":
		$MusicPlayer.stream = load("res://sounds/cereal_rap.ogg")
		
	$MusicPlayer.play()
	
func _on_StartTimer_timeout():
	if mode == "spaghetti":
		$MusicPlayer.stream = load("res://sounds/italian_theme.ogg")
	elif mode == "cereal":
		$MusicPlayer.stream = load("res://sounds/cereal_theme.ogg")
		
	$MusicPlayer.play()
	$MobTimer.start()


func _on_MobTimer_timeout():
	var mob
	if mode == "spaghetti":
		mob = mob_scene.instantiate()
		mob.connect("missed_plate", Callable(self, "_on_missed_plate"))
	elif mode == "cereal":
		mob = cereal_scene.instantiate()
		mob.connect("missed_bowl", Callable(self, "_on_missed_plate"))
		
	var dif_mod
	
	match player_difficulty:
		"EASY": dif_mod = DIF_MOD_EASY
		"MEDIUM": dif_mod = DIF_MOD_MEDIUM
		"HARD": dif_mod = DIF_MOD_HARD
		"EXTREME": dif_mod = DIF_MOD_EXTREME
		_: dif_mod = DIF_MOD_MEDIUM
	
	var velocity = Vector2(randf_range(randf_range(100.0/dif_mod, 200.0*dif_mod), randf_range(100.0/dif_mod, 200.0*dif_mod)), 0.0)
	var spawn_location = Vector2(SCREEN_WIDTH, randf_range(0.0, SCREEN_HEIGHT))
	
	mob.position = spawn_location
	mob.linear_velocity = velocity.rotated(PI)
	add_child(mob)
	
	$MobTimer.wait_time = randf_range(2.0 / dif_mod, 2.0)
	

#called when the player catches a plate
func _on_Player_caught_plate(body):
	score += 1
	$HUD.update_score(score)
	body.queue_free()
	$SFXPlayer.stop()
	$SFXPlayer.stream = load("res://sounds/gulp.ogg")
	$SFXPlayer.play()

#called when the player misses a plate
func _on_missed_plate(body):
	if body.position.x <= 1:
		num_missed += 1
		$SFXPlayer.stop()
		$SFXPlayer.stream = load("res://sounds/game_over.ogg")
		$SFXPlayer.play()
	if player_difficulty == "EASY" and num_missed >= DIF_EASY:
		game_over()
	elif player_difficulty == "MEDIUM" and num_missed >= DIF_MEDIUM:
		game_over()
	elif player_difficulty == "HARD" and num_missed >= DIF_HARD:
		game_over()
	elif player_difficulty == "EXTREME" and num_missed >= DIF_EXTREME:
		game_over()


func _on_HUD_show_options():
	$HUD/Options.show()
	
func _on_Options_back_to_main():
	$HUD/Options.hide()


func _on_Options_toggle_SFX(value):
	sfx_enabled = value
	if sfx_enabled: $SFXPlayer.set_volume_db(0)
	else: $SFXPlayer.set_volume_db(-80)

func _on_Options_toggle_music(value):
	music_enabled = value
	if music_enabled: $MusicPlayer.set_volume_db(0)
	else: $MusicPlayer.set_volume_db(-80)


func _on_Options_change_sprite(spr):
	player_sprite = SPRITE_LIST[spr]


func _on_Options_change_difficulty(dif):
	player_difficulty = DIFFICULTY_LIST[dif]


func _on_HUD_cereal_time(s):
	mode = s
	if mode == "spaghetti":
		$MusicPlayer.stream = load("res://sounds/spaghetti_menu.ogg")
	elif mode == "cereal":
		$MusicPlayer.stream = load("res://sounds/cereal_rap.ogg")
	
	$MusicPlayer.play()
