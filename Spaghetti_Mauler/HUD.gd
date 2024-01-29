extends CanvasLayer

signal start_game
signal show_options
signal cereal_time(s)

var mode = "spaghetti"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if mode == "spaghetti":
		$txSpaghett.show()
		$txReeses.hide()
	elif mode == "cereal":
		$txReeses.show()
		$txSpaghett.hide()
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()
	
func show_game_over(score):
	show_message("Game over tard-o!\nYour score was: "+ str(score))
	await $MessageTimer.timeout
	
	if mode == "spaghetti":
		$MessageLabel.text = "MAUL THAT SPAGHETT!"
		$txSpaghett.show()
	elif mode == "cereal":
		$MessageLabel.text = "KILL THAT CEREAL!"
		$txReeses.show()

	$MessageLabel.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()
	$btnOptions.show()
	$btnCereal.show()
	$ScoreLabel.hide()

func update_score(score):
	$ScoreLabel.text = str(score)

func update_difficulty(dif):
	$DifficultyButton.text = dif

func _on_MessageTimer_timeout():
	$MessageLabel.hide()

func _on_StartButton_pressed():
	$StartButton.hide()
	$btnOptions.hide()
	$btnCereal.hide()
	$txSpaghett.hide()
	$txReeses.hide()
	emit_signal("start_game")



func _on_btnOptions_pressed():
	emit_signal("show_options")


func _on_btnCereal_pressed():
	if mode == "spaghetti":
		mode = "cereal"
		$txSpaghett.hide()
		$txReeses.show()
		$btnCereal.text = "MAUL Spaghett!"
		$MessageLabel.text = "KILL THAT CEREAL PSYCHO!"
	elif mode == "cereal":
		mode = "spaghetti"
		$txReeses.hide()
		$txSpaghett.show()
		$btnCereal.text = "KILL Cereal!"
		$MessageLabel.text = "MAUL THAT SPAGHETT BOI!"
	
	emit_signal("cereal_time", mode)
