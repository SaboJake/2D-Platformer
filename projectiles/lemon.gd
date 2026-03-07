extends Area2D

var speed = 1000
var velocity = Vector2()
var direction = 1

func _ready():
	pass # Replace with function body.

func get_dir(dir):
	if dir != direction:
		$Sprite.flip_h = !$Sprite.flip_h
	direction = dir

func dash_speed(is_dashing):
	if is_dashing:
		speed = 1500
	else:
		speed = 1000

func _physics_process(delta):
	velocity.x = speed * direction * delta
	translate(velocity)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
