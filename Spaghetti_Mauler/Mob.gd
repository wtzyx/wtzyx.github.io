extends RigidBody2D

signal missed_plate
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	#Missed plates
func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("missed_plate", self)
	queue_free()
