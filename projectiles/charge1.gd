extends Area2D

var speed = 1200
var velocity = Vector2()
var direction = 1

onready var anim = $AnimatedSprite

func _ready():
	pass # Replace with function body.

func get_dir(dir):
	if dir != direction:
		anim.flip_h = !anim.flip_h
	direction = dir
	
func _physics_process(delta):
	if !anim.is_playing():
		anim.play("shoot_start")
	velocity.x = speed * direction * delta
	translate(velocity)


func _on_AnimatedSprite_animation_finished():
	if anim.get_animation() == "shoot_start":
		anim.play("shoot")

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
