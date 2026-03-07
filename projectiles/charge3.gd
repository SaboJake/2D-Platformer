extends Node2D

onready var timer_o = $NewEffectTimerO
const CHARGE3_O = preload("res://projectiles/charge3_o.tscn")
const SMALL_TEXTURE = preload("res://anims/X/projectiles/charge3_o_3_s.png")

onready var start_time

# Called when the node enters the scene tree for the first time.
func _ready():
	$Orange.time = 0.0
	timer_o.start()

var new_effect
var next = 3
var old_effect = get_child(next - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func copy():
	new_effect.time = old_effect.time
	new_effect.position = old_effect.position
	new_effect.velocity = old_effect.velocity
	new_effect.phi = old_effect.phi
	pass

func _on_NewEffectTimerO_timeout():
	add_child(CHARGE3_O.instance())
	new_effect = get_child(next)
	old_effect = get_child(next - 1)
	new_effect.set_texture($Small.get_texture())
	copy()
	new_effect.time = old_effect.time - 0.01
	next += 1
	if next == 4:
		timer_o.stop()
		timer_o.start()
	pass
	
