extends Sprite

# A sin(wt = phi)

var amplitude = 3000
var phi
var w = 12*PI/2
var time
onready var initial_pos = position
onready var Ok = true

var v0_x = 10000
var acceleration_x = 200000

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_position():
	var new_pos = Vector2()
	new_pos.x = initial_pos.x + velocity.x
	new_pos.y = initial_pos.y + velocity.y
	if Ok:
		return new_pos
	else:
		return initial_pos

func _input(event):
	if event.is_action_pressed("ui_home"):
		Ok = true

func _physics_process(delta):
	if Ok:
		time += delta
		velocity.y = amplitude * sin(w * time + phi) * delta
		velocity.x = (acceleration_x / 2 * time * time + v0_x * time) * delta * get_parent().get_parent().direction
		set_position(update_position())
