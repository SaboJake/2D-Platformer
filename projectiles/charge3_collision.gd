extends CollisionShape2D

onready var initial_pos = position
var velocity = Vector2()
var time = 0

var v0_x = 10000
var acceleration_x = 200000

func update_position():
	var new_pos = Vector2()
	new_pos.x = initial_pos.x + velocity.x
	new_pos.y = initial_pos.y + velocity.y
	return new_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	time += delta
	velocity.x = (acceleration_x / 2 * time * time + v0_x * time) * delta * get_parent().direction
	set_position(update_position())

