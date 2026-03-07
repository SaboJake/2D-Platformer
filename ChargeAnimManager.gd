extends Node2D

const CHARGE_ANIM1 = preload("res://charge/Charge1.tscn")

var cnt = -1
var Ok = false
var is_charging
var is_charging2

var charge_level = 0

func update_charge_level(level):
	charge_level = level

func _ready():
	pass

func incr():
	cnt += 1
	if cnt == 8:
		Ok = true
		cnt = 0
	else:
		Ok = false

func is_cycle_over():
	return Ok

func set_charging(charge_flag):
	is_charging = charge_flag
	
func set_charging_lvl2(charge_flag):
	is_charging2 = charge_flag

func add_anim():
	if charge_level > 0:
		incr()
		var charge1 = CHARGE_ANIM1.instance()
		charge1.det_sprite_frames(charge_level)
		charge1.set_rotation(cnt)
		add_child(charge1)
	

func charge1():
	add_anim()

