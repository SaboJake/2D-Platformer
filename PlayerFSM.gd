#Very important script, maynly used for:
#	- animation management via the state machine
#   - movement
#	- shooting and charging
#
#
#Calls a lot of other scripts such as:
#	- PaletteManager (refered to as p_m)
#	-
extends StateMachine

var run_timer = Timer.new()

const LEMON = preload("res://projectiles/lemon.tscn")
const CHARGE1 = preload("res://projectiles/charge1.tscn")
const CHARGE2 = preload("res://projectiles/charge2.tscn")
const CHARGE3 = preload("res://projectiles/charge3.tscn")


onready var charge_anims = parent.get_node("Body/ChargeAnims")
onready var p_m = parent.get_node("PaletteManager")
onready var weapon_screen = parent.get_node("UI/WeaponSelect")

#Ready function used for adding all the states used in the script
func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("land")
	add_state("wall_slide")
	add_state("wall_jump")
	add_state("dash")
	add_state("air_dash")
	add_state("up_dash")
	add_state("up_dash_end")
	add_state("shoot")
	call_deferred("set_state", states.idle)
	run_timer.connect("timeout", self, "_on_run_timeout")
	add_child(run_timer)
#Flags
var initial_dash_direction = 1
var can_air_dash = true
var is_shooting = false
var is_running = false
var is_landing = false
var is_turning = false
var stopped_dashing = false
var can_shoot = true
var is_charging = false
var is_charging_lvl2 = false
var is_c_shot_on_screen = false
#Variables used for shooting
const MAX_LEMONS = 3
var lemons = []
var charge_shots = []
var stored_shot_flag = false
var stored_shot

var current_weapon = 0 #Sets the current weapon to the x buster
#Spawns a Projectile!
func _shoot_lemon(lemon):
	var coef = 1
	if state == states.wall_slide:
		coef = -1
	parent.get_parent().add_child(lemon)
	lemon.position = parent.shoot_pos.global_position
	lemon.get_dir(parent.get_node("Body").scale.x * coef)
#Used for shooting animations
func _shoot_routine(can_shoot1):
		if state != states.shoot and can_shoot1:
			is_shooting = true
			parent.shoot_timer.start()
		else:
			if can_shoot1:
				parent.x_anims.set_frame(0)
				parent.armor_set_frame(0, 0)
				parent.x_anims.play("shoot_idle")
				parent.armor_play("shoot_idle", false)
				parent.shoot_timer.start()
#Oh boy there is a lot of stuff here...
func _input(event):
	#Jumping and falling through platforms
	if [states.idle, states.run, states.dash, states.shoot].has(state):
		if event.is_action_pressed("jump"):
			if Input.is_action_pressed("down"):
				if parent._check_is_grounded(parent.get_node("DropThruRaycasts")):
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
			else:
				parent.velocity.y = parent.max_jump_velocity
				parent.is_jumping = true
	#Dashing
	if [states.idle, states.run, states.dash, states.shoot].has(state):
		if event.is_action_pressed("dash") and parent.wall_direction == 0:
			can_air_dash = false
			if parent.is_dashing:
				set_state(states.idle)
				parent.velocity.x = 0
			parent.is_dashing = true
			initial_dash_direction = parent.get_node("Body").scale.x
			parent.dash_timer.start(0.5)
	#Air Dashing
	if [states.fall, states.jump, states.wall_jump].has(state):
		if event.is_action_pressed("dash") and can_air_dash:
			if Input.is_action_pressed("move_up"):
				parent.is_up_dashing = true
				parent.dash_timer.start(0.2)
			else:
				parent.is_air_dashing = true
				initial_dash_direction = parent.get_node("Body").scale.x
				parent.dash_timer.start(0.5)
			can_air_dash = false
			parent.is_dashing = true
	#Cancel Up Dash
	if state == states.up_dash:
		if event.is_action_released("dash"):
			parent.is_up_dashing = false
			parent.gravity = 1750
			set_state(states.up_dash_end)
	#Cancel Jump
	if state == states.jump:
		if event.is_action_released("jump") and parent.velocity.y < 0:
			parent.velocity.y = 0
	if state == states.wall_jump:
		if event.is_action_released("jump") and parent.velocity.y < -200:
			parent.velocity.y = -200
	#Wall Jumping + Wall Dashing
	elif state == states.wall_slide:
		if event.is_action_pressed("dash") and !parent.is_air_dashing:
			can_air_dash = false
			parent.wall_dash_timer.start()
		if event.is_action_pressed("jump"):
			if parent.wall_dash_timer.is_stopped():
				parent.wall_jump(Vector2(0, 0))
			else:
				parent.wall_jump(Vector2(-1000 * parent.wall_direction, 0))
				parent.is_dashing = true
				can_air_dash = false
				parent.wall_dash_timer.stop()
			set_state(states.wall_jump)
	#Shooting
	if !parent.is_up_dashing and event.is_action_pressed("shoot"):
		var lemon
		if !stored_shot_flag:
			lemon = LEMON.instance()
		else:
			lemon = stored_shot.instance()
		var coef = 1
		var cnt = 0
		#Check how many lemons are on screen
		for l in lemons:
			if  is_instance_valid(l):
				cnt += 1
			else:
				lemons.erase(l)
		#If there are less than 3 lemons, then we can shoot
		if cnt < MAX_LEMONS:
			if !stored_shot_flag:
				lemon.dash_speed(parent.is_dashing)
			else:
				is_c_shot_on_screen = true
			can_shoot = true
			lemons.push_back(lemon)#add new lemon
			_shoot_lemon(lemon)
			stored_shot_flag = false
			current_charge_anim = "charge"
		else:
			can_shoot = false
		_shoot_routine(can_shoot)
	#Charging
	if event.is_action_pressed("shoot"):
		parent.charge_timer1.start()
		weapon_screen.can_charge = false
	if event.is_action_released("shoot") or !Input.is_action_pressed("shoot"):
		var charge_level = charge_anims.charge_level
		if charge_level > 0:
			var charge_shot
			match charge_level:
				1:
					charge_shot = CHARGE1.instance()
				2:
					charge_shot = CHARGE2.instance()
				3:
					charge_shot = CHARGE3.instance()
					stored_shot = CHARGE1
					stored_shot_flag = true
				4:
					charge_shot = CHARGE3.instance()
					stored_shot = CHARGE2
					stored_shot_flag = true
			is_c_shot_on_screen = false
			for s in charge_shots:
				if is_instance_valid(s):
					is_c_shot_on_screen = true
				else:
					charge_shots.erase(s)
			if !is_c_shot_on_screen:
				charge_shots.push_back(charge_shot)
				_shoot_lemon(charge_shot)
				_shoot_routine(true)
				if stored_shot_flag:
					parent.charge_anim_timer.start()
				#if charge_level == 3:
				#	charge_shots.push_back(CHARGE1.instance())
				#if charge_level == 4:
				#	charge_shots.push_back(CHARGE2.instance())
		is_charging = false
		weapon_screen.stop_charging = false
		charge_anims.update_charge_level(0)
		is_charging_lvl2 = false
		parent.charge_timer1.stop()
		parent.charge_timer2.stop()
		parent.charge_timer3.stop()
		parent.charge_timer4.stop()
		if !stored_shot_flag:
			parent.charge_anim_timer.stop()
			current_charge_anim = "charge"
		#p_m.set_palette(parent.curr_weapons[current_weapon])
		p_m.set_palette(p_m.active_weapon)
	#Switching Weapons
	if event.is_action_pressed("switch_l"):
		var weapons = parent.curr_weapons
		current_weapon = weapons.find(p_m.active_weapon)
		if current_weapon == weapons.size() - 1:
			current_weapon = 0
		else:
			current_weapon += 1
		p_m.set_weapon(weapons[current_weapon])
	if event.is_action_pressed("switch_r"):
		var weapons = parent.curr_weapons
		current_weapon = weapons.find(p_m.active_weapon)
		if current_weapon == 0:
			current_weapon = weapons.size() - 1
		else:
			current_weapon -= 1
		p_m.set_weapon(weapons[current_weapon])

func _state_logic(delta):
	#parent.x_anims.visible = false
	#parent.x_action_anims.visible = false
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._handle_move_input()
	parent._apply_gravity(delta)
	if state  == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_stickying()
	parent._apply_movement()
	#print(Engine.get_frames_per_second())

func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif (parent.velocity.x != 0 and !parent.is_dashing):
				return states.run
			elif is_shooting:
				return states.shoot
			elif parent.is_dashing:
				return states.dash
			#return states.idle

		states.run:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0 and !is_turning:
				is_turning = true
				run_timer.start(0.05)
				return states.run
			elif parent.is_dashing:
				return states.dash
			return states.run

		states.jump:
			if parent.is_air_dashing:
				return states.air_dash
			elif parent.is_up_dashing:
				return states.up_dash
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.land
			elif parent.velocity.y >= 0:
				return states.fall

		states.fall:
			if parent.is_air_dashing:
				return states.air_dash
			elif parent.is_up_dashing:
				return states.up_dash
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.land
			elif parent.velocity.y < 0:
				#return states.jump
				pass

		states.land:
			if parent.velocity.x == 0:
				return states.idle
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run

		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
			if parent.wall_direction == 1:
				if Input.is_action_just_released("move_right"):
					parent.velocity.x -= 100 
					parent.wall_slide_cooldown.start()
			elif parent.wall_direction == -1:
				if Input.is_action_just_released("move_left"):
					parent.velocity.x += 100
					parent.wall_slide_cooldown.start()
			parent.is_dashing = false

		states.wall_jump:
			if parent.is_air_dashing:
				return states.air_dash
			elif parent.is_up_dashing:
				return states.up_dash

		states.dash:
			if parent.move_direction == 0 and !parent.is_dashing:
				return states.idle
			elif parent.is_jumping or parent.velocity.y > 0:
				return states.jump
			if initial_dash_direction != parent.get_node("Body").scale.x and parent.is_on_floor():
				parent.is_dashing = false
				is_running = true
				stopped_dashing = false
				parent.x_anims.play("run")
				parent.armor_play("run", false)
				return states.run
			if parent.wall_direction != 0 and parent.is_on_floor():
				parent.is_dashing = false
				return states.idle
			
		states.air_dash:
			if initial_dash_direction != parent.get_node("Body").scale.x and parent.is_air_dashing:
				parent.gravity = 1750
				return states.fall
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				parent.gravity = 1750
				parent.is_dashing = false
				return states.wall_slide
			if parent.is_on_floor():
				return states.idle
		
		states.shoot:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0 and !parent.is_dashing:
				return states.run
			elif parent.is_dashing:
				return states.dash
			elif !is_shooting:
				return states.idle
		
	return null

func _enter_state(new_state, old_state):
	#print(parent.shoot_pos.position.x)
	match new_state:
		states.idle:
			parent.shoot_pos.position = Vector2(58.667, -6)
			if !is_landing and !stopped_dashing and parent.velocity.x == 0:
				parent.x_anims.play("idle")
				parent.armor_play("idle", false)
				#parent.armor_play("jump_land")
				#parent.x_anims.play("jump_land")
			is_running = false
			parent.is_dashing = false

		states.run:
			parent.shoot_pos.position = Vector2(75, -14)
			if !is_running and !is_turning:
				parent.x_anims.play("run_start")
				parent.armor_play("run_start", false)
			if is_turning:
				parent.x_anims.play("idle")
				parent.armor_play("idle", false)
			is_landing = false
			stopped_dashing = false

		states.jump:
			parent.x_anims.play("jump_start")
			parent.armor_play("jump_start", false)
			is_running = false
			is_landing = false

		states.fall:
			parent.shoot_pos.position = Vector2(80, -34)
			parent.x_anims.play("jump_down")
			parent.armor_play("jump_down", false)
			is_running = false
			is_landing = false

		states.land:
			if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
				parent.armor_play("jump_land", false)
				parent.x_anims.play("jump_land")
				is_running = false
			else:
				parent.x_anims.play("run")
				parent.armor_play("run", false)
				is_running = true
			is_landing = true

		states.wall_slide:
			parent.x_anims.play("walljump_on")
			parent.armor_play("walljump_on", false)
			parent.get_node("Body").scale.x = parent.wall_direction

		states.wall_jump:
			parent.is_wall_sliding = true
			#sparent.get_node("Body").scale.x = parent.wall_direction
			parent.x_anims.play("walljump_off")
			parent.armor_play("walljump_off", false)

		states.dash:
			#parent.shoot_pos.position = Vector2(106, 14)
			parent.x_anims.play("dash")
			parent.armor_play("dash", false)

		states.air_dash:
			parent.x_anims.play("dash")
			parent.armor_play("dash", false)
			parent.gravity = 0
			parent.velocity.y = 0

		states.up_dash:
			parent.x_anims.play("dash_up")
			parent.armor_play("dash_up", false)
			parent.gravity = 0
			parent.velocity.y = 0
			parent.dash_velocity = 0
			parent.up_dash_dellay.start()
			
		states.up_dash_end:
			parent.x_anims.play("dash_up_end")
			parent.armor_play("dash_up_end", false)
			
		states.shoot:
			parent.x_anims.play("shoot_idle")
			parent.armor_play("shoot_idle", false)

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			#parent.armor_play("NULL", false)
			pass
		
		states.wall_slide:
			parent.wall_slide_cooldown.start()
			if !parent.is_dashing:
				can_air_dash = true

		states.wall_jump:
			pass

		states.fall:
			if !parent.is_air_dashing:
				parent.is_dashing = false
				if !parent.is_dashing and !parent.is_up_dashing:
					can_air_dash = true

		states.air_dash:
			parent.is_air_dashing = false
			
		states.up_dash:
			parent.is_up_dashing = false

		states.up_dash_end:
			parent.dash_velocity = 800

		states.dash:
			if parent.is_on_floor() and state != states.run:
				parent.x_anims.play("dash_end")
				parent.armor_play("dash_end", false)
				stopped_dashing = true

		states.shoot:
			if is_shooting:
				parent.x_action_anims.visible = true
				parent.armor_visible(true, true)
				parent.x_anims.visible = false
				parent.armor_visible(false, false)
				pass
			if state == states.idle:
				parent.x_anims.play("idle")
				parent.armor_play("idle", false)
				pass

func _on_animation_finished():
	match parent.x_anims.get_animation():
		"run_start":
			is_running = true
			parent.x_anims.play("run")
			parent.armor_play("run", false)

		"jump_land":
			is_landing = false
			parent.is_dashing = false
			parent.x_anims.play("idle")
			parent.armor_play("idle", false)

		"walljump_off":
			set_state(states.fall)
			parent.is_wall_sliding = false

		"dash_end":
			stopped_dashing = false
			parent.x_anims.play("idle")
			parent.armor_play("idle", false)
		
		"dash_up_end":
			set_state(states.fall)
			
		"shoot_idle":
			#parent.shoot_timer.start()
			pass

func _on_AnimatedSprite_frame_changed():
	match parent.x_anims.get_animation():
		"dash":
			if parent.x_anims.get_frame() < 2:
				parent.shoot_pos.position = Vector2(86, -2)
			else:
				parent.shoot_pos.position = Vector2(106, 14)
		"jump_start":
			if parent.x_anims.get_frame() < 3:
				parent.shoot_pos.position = Vector2(65, -20)
			else:
				parent.shoot_pos.position = Vector2(68, -30)
		"walljump_on":
			if parent.x_anims.get_frame() < 5:
				parent.shoot_pos.position = Vector2(-12, -26)
			else:
				parent.shoot_pos.position = Vector2(-71, 3)
		"walljump_off":
			if parent.x_anims.get_frame() < 4:
				parent.shoot_pos.position = Vector2(62, -28)
			elif parent.x_anims.get_frame() < 10:
				parent.shoot_pos.position = Vector2(72, -18)
			else:
				parent.shoot_pos.position = Vector2(68, -30)

#Timers
func _on_run_timeout():
	is_turning = false
	if state == states.run:
		if parent.velocity.x == 0:
			set_state(states.idle)
		elif is_running:
			parent.x_anims.play("run")
			parent.armor_play("run", false)

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)

func _on_DashTimer_timeout():
	if parent.is_on_floor():
		parent.velocity.x = 0
		parent.is_dashing = false
		set_state(states.idle)
	elif parent.is_air_dashing:
		parent.is_air_dashing = false
		set_state(states.fall)
		parent.gravity = 1750
	elif parent.is_up_dashing:
		parent.is_up_dashing = false
		parent.gravity = 1750
		set_state(states.up_dash_end)

func _on_WallDashTimer_timeout():
	pass

func _on_UpDashDellay_timeout():
	parent.velocity.y = -800

func _on_ShootTimer_timeout():
	is_shooting = false

var charge_cnt = 0

var current_charge_anim = "charge"

#After the charge timer stops, X has reached that charge level
func _on_ChargeTimer1_timeout():
	charge_anims.update_charge_level(1)
	is_charging = true
	charge_anims.charge1()
	parent.charge_timer2.start()
	parent.charge_anim_timer.start()
	
func _on_ChargeTimer2_timeout():
	is_charging_lvl2 = true
	charge_anims.update_charge_level(2)
	parent.charge_timer3.start()

func _on_ChargeTimer3_timeout():
	current_charge_anim = "charge2"
	charge_anims.update_charge_level(3)
	parent.charge_timer4.start()

var charge_palette_flag = false

func _on_ChargeTimer4_timeout():
	current_charge_anim = "charge3"
	charge_anims.update_charge_level(4)
	
func _on_ChargeAnimTimer_timeout():
	charge_palette_flag = !charge_palette_flag
	p_m.charge_anim(charge_palette_flag, current_charge_anim)

