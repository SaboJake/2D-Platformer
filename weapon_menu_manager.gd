extends Control

onready var palette_manager = get_parent().get_parent().get_node("PaletteManager")
onready var state_machine = get_parent().get_parent().get_node("StateMachine")

var stop_charging = false
var can_charge = false

func _ready():
	weapons["default"] = weapon_list.get_child(0)

var is_paused = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("weapon_screen"):
		if !is_paused:
			weapons[palette_manager.active_weapon].grab_focus()
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

const WEAPON = preload("res://Weapon.tscn")
onready var weapon_list = $Outline/Weapons

var weapons = {}

var bar_colour = {
	"charge":  null,
	"x_buster": Color("#F8C000"),
	"acid_b":  Color("#6080C0"),
	"p_bomb":  Color("#40E080"),
	"triad_t": Color("#404040"),
	"s_blade": Color("#E0A020"),
	"ray_s":   Color("#C0C000"), 
	"g_well":  Color("#6020C0"),
	"frost_s": Color("#E0E000"), 
	"t_fang":  Color("E04000")
}

func get_weapon_name(weapon):#processes the weapon name for the display
	var ans = weapon
	if weapon[-2] == '_':
		ans[-2] = ' '
		ans += "."
	else:
		if ans[0] == 'x':
			ans[1] = ' '
		else:
			ans[1] = '.'
	return ans

func add_weapon(weapon):
	var curr_weapon = WEAPON.instance()
	weapons[weapon] = curr_weapon
	curr_weapon.weapon = weapon
	curr_weapon.get_node("Label").text = get_weapon_name(weapon)
	curr_weapon.get_node("Icon").texture = load("res://ui/icons/weapon_screen/" + weapon + ".png")
	curr_weapon.get_node("outline/bg_bar").set_tint_progress(bar_colour[weapon])
	weapon_list.add_child(curr_weapon)
