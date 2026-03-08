extends Button

var weapon = "x_buster"

onready var weapon_screen = get_parent().get_parent().get_parent()
onready var palette_manager = weapon_screen.get_parent().get_parent().get_node("PaletteManager")

func _ready():
	modulate = Color(0.5, 0.5, 0.5)

func _on_Weapon_focus_entered():
	modulate = Color(1, 1, 1)
	print(weapon)
	if palette_manager.is_ready:
		palette_manager.set_weapon(weapon)

func _on_Weapon_focus_exited():
	modulate = Color(0.5, 0.5, 0.5)
