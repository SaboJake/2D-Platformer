extends NinePatchRect

onready var rect = rect_size
onready var bar = $bg_bar

const min_bars = 16

func set_maximum(no_bars):#sets maximum number of bars, current minimum is 16
	rect_size.x = rect.x + 8*(no_bars - min_bars)
	
func set_current(no_bars):
	$bg_bar.value = no_bars
	$fg_bar.value = no_bars
	
func _ready():
	#set_maximum(22)
	#set_current(19)
	pass

