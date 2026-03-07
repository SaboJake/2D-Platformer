extends Node2D

onready var parent = get_parent()
onready var anim = parent.get_node("Body/AnimatedSprite")
onready var action_anim = parent.get_node("Body/ActionAnimatedSprite")
onready var weapon_bar = parent.get_parent().get_node("UI/Bar2")

onready var is_ready = true

var armors
var action_armors

var palettes = ["charge", "default", "acid_b", "p_bomb", "triad_t",
				"s_blade", "ray_s", "g_well", "frost_s", "t_fang"] 

var bar_colour = {
	"charge":  null,
	"default": Color(),
	"acid_b":  Color("#6080C0"),
	"p_bomb":  Color("#40E080"),
	"triad_t": Color("#404040"),
	"s_blade": Color("#E0A020"),
	"ray_s":   Color("#C0C000"), 
	"g_well":  Color("#6020C0"),
	"frost_s": Color("#E0E000"), 
	"t_fang":  Color("E04000")
}

func get_palette(var palette):
	return "res://palettes/X/" + palette + ".png"

func get_icon(palette):
	return "res://ui/icons/" + palette + ".png"
	

func set_armors(ar1, ar2):
	armors = ar1
	action_armors = ar2

var active_weapon = "default"

func set_weapon(weapon):
	if weapon == "x_buster":
		weapon = "default"
	active_weapon = weapon
	set_palette(weapon)
	weapon_bar.set_visible(weapon != "default")
	weapon_bar.get_node("bg_bar").set_tint_progress(bar_colour[weapon])
	if weapon != "default":
		weapon_bar.get_node("Icon").texture = load(get_icon(weapon))
	

func set_palette(palette_):
	palette_ = get_palette(palette_)
	anim.material.set_shader_param("palette", load(palette_))
	action_anim.material.set_shader_param("palette", load(palette_))
	for armor in armors:
		armor.material.set_shader_param("palette", load(palette_))
	for armor in action_armors:
		armor.material.set_shader_param("palette", load(palette_))

func charge_anim(Ok, charge_anim):
	if Ok:
		set_palette(active_weapon)
	else:
		set_palette(charge_anim)

func _ready():
	print("amogus")
	pass
