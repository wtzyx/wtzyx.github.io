extends Area2D

signal caught_plate
const DEFAULT_SPEED = 500
const MAX_SPEED = 750

var SCREEN_WIDTH
var SCREEN_HEIGHT
var cur_speed
var move_to_pos = Vector2.ZERO
var player_sprite = "Drumpf" # default sprite, player picks in options
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SCREEN_WIDTH = get_viewport_rect().size.x
	SCREEN_HEIGHT = get_viewport_rect().size.y
	hide()

#set the player sprite here
func set_player_sprite(spr):
	player_sprite = spr
	
func get_screen_width():
	return SCREEN_WIDTH

func get_screen_height():
	return SCREEN_HEIGHT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if move_to_pos.length() > 0:
		move_to_pos = Vector2(position.x, move_to_pos.y)
		if position.distance_to(move_to_pos) < 5:
			move_to_pos = Vector2.ZERO
			cur_speed = 0.0
		else:
			if (move_to_pos.y > position.y):
				velocity.y += 1
			if (move_to_pos.y < position.y):
				velocity.y -= 1
			
			if velocity.length() > 0:
				cur_speed = abs(cur_speed)
				if cur_speed > MAX_SPEED: cur_speed = MAX_SPEED
				
				velocity = velocity.normalized() * cur_speed
			
			position += velocity * delta
		
			
		position.y = clamp(position.y, -50, SCREEN_HEIGHT - 55)

func hide_all_sprites():
	$Drumpf.visible = false
	$CollisionShapeDrumpf.disabled = true
	$Torler.visible = false
	$Torler.stop()
	$CollisionShapeTorler.disabled = true
	$Elon.visible = false
	$Elon.stop()
	$CollisionShapeElon.disabled = true
	$Pope.visible = false
	$Pope.stop()
	$CollisionShapePope.disabled = true
	$DrDrew.visible = false
	$CollisionShapeDrew.disabled = true

#sets up the player at the start of a game
func start(spr):
	hide_all_sprites()
	
	match spr:
		"Doland Drumpf": 
			$Drumpf.visible = true
			$CollisionShapeDrumpf.disabled = false
		"Torler Kurnz":
			$Torler.visible = true
			$CollisionShapeTorler.disabled = false
			$Torler.play()
		"WaaElon":
			$Elon.visible = true
			$CollisionShapeElon.disabled = false
			$Elon.play()
		"Pope":
			$Pope.visible = true
			$CollisionShapePope.disabled = false
			$Pope.play()
		"Dr Drew":
			$DrDrew.visible = true
			$CollisionShapeDrew.disabled = false
			$DrDrew.play()
				
	show()

	
#shuts down the player on game over
func game_over():
	hide_all_sprites()
	hide()

#handle player input
func _input(event): 
	if event is InputEventScreenTouch:
		cur_speed = DEFAULT_SPEED
		move_to_pos = event.position
			
	if event is InputEventScreenDrag:
		move_to_pos = event.position
		cur_speed = event.velocity.y
		
	position.y = clamp(position.y, -50, SCREEN_HEIGHT - 55)

#called when something collides with player.collisionshape2d
func _on_Player_body_entered(body):
	emit_signal("caught_plate", body)
