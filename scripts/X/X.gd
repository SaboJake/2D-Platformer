extends KinematicBody2D

signal grounded_updated(is_grounded)

const UP = Vector2(0, - 1)
const SLOPE_STOP = 128
const DROP_THRU_BIT = 1
const WALL_JUMP_VELOCITY = Vector2(-2700, -700)
const MAX_FALL_SPEED = 1000

var velocity = Vector2()
var move_speed = 4 * 80
var gravity = 1750
var dash_velocity = 800
var max_jump_velocity = -800
var min_jump_velocity
#flags
var is_grounded
var is_jumping = false
var is_running = false
var is_dashing = false
var is_air_dashing = false
var wall_direction = 1
var move_direction = 1
var is_wall_sliding = false
var is_up_dashing = false

var has_max_armor = [0, 0, 0, 0] #Gucci Shoes, Buster, Chest, Helmet
var has_giga_armor = [0, 0, 0, 0]

var has_weapons = [0, 1, 0, 0, 1, 1, 0, 1, 1, 1] #Weapon checker, first one is unused
#charge, default, acid_b, p_bomb, triad_t, s_blade, ray_s, g_well, frost_s, t_fang
var armor_checkers = [
	has_giga_armor,
	has_max_armor
]
#Objects
onready var raycasts = $Raycasts
onready var x_anims = $Body/AnimatedSprite
onready var x_action_anims = $Body/ActionAnimatedSprite
onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer
onready var dash_timer = $DashTimer
onready var wall_dash_timer = $WallDashTimer
onready var up_dash_dellay = $UpDashDellay
onready var shoot_timer = $ShootTimer
onready var charge_timer1 = $ChargeTimer1
onready var charge_timer2 = $ChargeTimer2
onready var charge_timer3 = $ChargeTimer3
onready var charge_timer4 = $ChargeTimer4
onready var charge_anim_timer = $ChargeAnimTimer
onready var shoot_pos = $Body/ShootPosition
onready var palette_manager = $PaletteManager
onready var weapon_screen = $UI/WeaponSelect

onready var armors = [
	$Body/GigaArmor,
	$Body/MaxArmor
]

onready var action_armors = [
	$Body/ActionGigaArmor,
	$Body/ActionMaxArmor
]

onready var active_armors = []
onready var active_action_armors = [] 

#X will always have the X buster, thus setting the weapons
#to have "default"
var curr_weapons = ["default"]

func _ready():
	#weapon_screen.add_weapon("acid_b")
	var cnt1 = 0
	#Builds Weapons Array and adds weapons to the weapons screen
	for i in range(2, 10):
		if has_weapons[i]:
			curr_weapons.push_back(palette_manager.palettes[i])
			weapon_screen.add_weapon(palette_manager.palettes[i])
	#Equips X's armors (normal sprite)
	for armor in armors:
		var cnt2 = 0
		var curr_item_checker = armor_checkers[cnt1]
		for child in armor.get_children():
			child.visible = curr_item_checker[cnt2]
			if(curr_item_checker[cnt2]):
				active_armors.push_back(child)
			cnt2 += 1		
		cnt1 += 1
	cnt1 = 0
	#Equips X's armors (action sprite)
	for armor in action_armors:
		var cnt2 = 0
		var curr_item_checker = armor_checkers[cnt1]
		for child in armor.get_children():
			child.visible = curr_item_checker[cnt2]
			if curr_item_checker[cnt2]:
				active_action_armors.push_back(child)
			cnt2 += 1		
		cnt1 += 1
	palette_manager.set_armors(active_armors, active_action_armors)

#Functions used for animating armors
#Ok = 0 - normal armor
#	  1 - active armor
func determinate_armor(Ok):
	if Ok:
		return active_action_armors
	else:
		return active_armors

func armor_play(animation, Ok):
	var armor = determinate_armor(Ok)
	for part in armor:
		part.play(animation)

func armor_set_frame(frame, Ok):
	var armor = determinate_armor(Ok)
	for part in armor:
		part.set_frame(frame)

func armor_set_animation(animation, Ok):
	var armor = determinate_armor(Ok)
	for part in armor:
		part.set_animation(animation)

func armor_set_playing(Ok1, Ok):
	var armor = determinate_armor(Ok)
	for part in armor:
		part._set_playing(Ok1)
			
func armor_visible(Ok1, Ok):
	var armor = determinate_armor(Ok)
	for part in armor:
		part.visible = Ok1

#Functions used for pgysics (movement, gravity etc.)
func _physics_process(delta):
	_handle_move_input()

func _apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

func _cap_gravity_wall_slide(): #Slow down while on the wall
	var max_velocity = 300
	velocity.y = min(velocity.y, max_velocity)

func _apply_movement():
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	if is_jumping and velocity.y >= 0:
		is_jumping = false
	
	is_grounded = !is_jumping and get_collision_mask_bit(DROP_THRU_BIT) and _check_is_grounded()

func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	if sign(shoot_pos.position.x) != move_direction and move_direction != 0:
		shoot_pos.position.x *= -move_direction

func wall_jump(dash_boost):
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= wall_direction
	velocity = wall_jump_velocity + dash_boost

func _handle_wall_slide_stickying(): #Cooldown for wall sliding
	if move_direction != 0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

func _get_h_weight(): #Lepring stuff
	#return 1.0
	if is_on_floor():
		if is_dashing:
			return 0.1
		else:
			return 1.0
	else:
		if move_direction == 0:
			return 0.2
		elif move_direction == sign(velocity.x) and abs(velocity.x) > move_speed:
			return 0.8
		else:
			return 0.2

func _get_speed_x(): #Horizontal speed
	var ans
	if !is_dashing:
		ans = move_speed * move_direction
	else:
		if (is_on_floor() or is_air_dashing) and move_direction == 0:
			ans = $Body.scale.x * dash_velocity
		else:
			ans = dash_velocity * move_direction
	return ans

var dash_cancel = false

func _handle_move_input(): #Moving left and right
	velocity.x = lerp(velocity.x, _get_speed_x(), _get_h_weight())
	var old_body_scale = $Body.scale.x
	if move_direction != 0:
		$Body.scale.x = move_direction

func _check_is_grounded(raycasts = self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false

func _update_wall_direction(): #What side of the wall is X on
	var is_near_left_wall = _check_is_valid_wall(left_wall_raycasts)
	var is_near_right_wall = _check_is_valid_wall(right_wall_raycasts)
	
	if is_near_left_wall and is_near_right_wall:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_left_wall) + int(is_near_right_wall)

func _check_is_valid_wall(wall_raycatsts): #More accurate is_on_wall(), mostly unused
	for raycast in wall_raycatsts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return true
	return false

func _on_Area2D_body_exited(body): #Go thruough platforms
	set_collision_mask_bit(DROP_THRU_BIT, true)
