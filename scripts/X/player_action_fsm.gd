extends StateMachine

func _ready():
	add_state("none")
	add_state("shoot")
	call_deferred("set_state", states.none)

onready var PlayerFSM = parent.get_node("StateMachine")

var is_shooting = false

func _get_transition(delta):
	match state:
		states.none:
			if PlayerFSM.is_shooting:
				return states.shoot
		states.shoot:
			if !PlayerFSM.is_shooting or (parent.is_on_floor() and parent.move_direction == 0 and !parent.is_dashing):
				return states.none

func _state_logic(delta):
	if PlayerFSM.is_shooting:
		var frame1 = parent.x_anims.get_frame()
		var anim = "shoot_" + parent.x_anims.get_animation()
		if anim != "shoot_shoot_idle" and anim != "shoot_idle":
			if anim != parent.x_action_anims.get_animation():
				if anim == "shoot_dash_up" or anim == "shoot_dash_up_end":
					pass
				else:
					parent.x_action_anims.set_animation(anim)
					parent.armor_set_animation(anim, true)
					parent.x_action_anims.set_frame(frame1)
					parent.armor_set_frame(frame1, true)
					parent.x_action_anims.play(anim)
					parent.armor_play(anim, true)
		

func _enter_state(new_state, old_state):
	match new_state:
		states.none:
			parent.armor_visible(false, true)
			parent.x_action_anims.visible = false
			parent.armor_visible(true, false)
			parent.x_anims.visible = true
			
			
func _exit_state(old_state, new_state):
	match old_state:
		states.none:
			if PlayerFSM.state != PlayerFSM.states.shoot:
				parent.armor_visible(true, true)
				parent.x_action_anims.visible = true
				parent.armor_visible(false, false)
				parent.x_anims.visible = false

func _on_ActionAnimatedSprite_animation_finished():
	match parent.x_action_anims.get_animation():
		"shoot_jump_land":
			parent.armor_visible(false, true)
			parent.x_action_anims.visible = false
			parent.armor_visible(true, false)
			parent.x_anims.visible = true
			PlayerFSM.is_landing = false
	
