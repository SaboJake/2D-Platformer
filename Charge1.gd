extends AnimatedSprite

onready var anim = get_node('/root') 

func _ready():
	anim.play("charge")
	
