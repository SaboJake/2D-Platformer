extends AnimatedSprite

var r = [0, 90, 45, -45, 30, -60, -30, 60]
var cycle_over

onready var parent = get_parent()

var frames1 = preload("res://charge/Charge1.tres")
var frames2 = preload("res://charge/Charge2.tres")
var frames3 = preload("res://charge/Charge3.tres")


var curr_frame

func set_rotation(cnt):
	set_rotation_degrees(r[cnt])

func det_sprite_frames(Ok):
	match Ok:
		1:
			curr_frame = frames1
		2:
			curr_frame = frames2
		3:
			curr_frame = frames3
		4:
			curr_frame = frames3

func _ready():
	set_sprite_frames(curr_frame)
	cycle_over = get_parent().is_cycle_over()
	play("default")

func _on_AnimatedSprite_animation_finished():
	if cycle_over:
		get_parent().add_anim()
	queue_free()

var Ok1 = false

func _on_AnimatedSprite_frame_changed():
	if get_frame() == 2 and !cycle_over:
		get_parent().add_anim()
		
	
