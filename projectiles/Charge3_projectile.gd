extends Area2D

onready var orange = $OrangeEffect
onready var green = $GreenEffect
onready var white = $WhiteEffect

var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	orange.get_node("Orange").phi = 0.0
	green.get_node("Orange").phi = PI/2
	white.get_node("Orange").phi = -PI/2

func get_dir(dir):
	direction = dir

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
