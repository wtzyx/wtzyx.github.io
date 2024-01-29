extends CanvasLayer

signal change_difficulty(dif)
signal change_sprite(spr)
signal toggle_music(bln)
signal toggle_SFX(bln)
signal back_to_main

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$optSprite/optDifficulty/chkMusic.set_pressed_no_signal(true)
	$optSprite/optDifficulty/chkSFX.set_pressed_no_signal(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_btnBack_pressed():
	emit_signal("back_to_main")


func _on_optSprite_item_selected(index):
	emit_signal("change_sprite", index)

func _on_chkMusic_toggled(button_pressed):
	emit_signal("toggle_music", button_pressed)


func _on_chkSFX_toggled(button_pressed):
	emit_signal("toggle_SFX", button_pressed)


func _on_optDifficulty_item_selected(index):
	emit_signal("change_difficulty", index)
