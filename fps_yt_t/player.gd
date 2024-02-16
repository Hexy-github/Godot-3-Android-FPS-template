extends KinematicBody

var gyro_sensitivity = -0.03
var invert_gyro = 1 # or -1
var gyroscope = Vector3.ZERO

var invert_screen_drag = 1 # or -1
var drag_sensitivity = -.003


var speed = 20
var player_direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var snap = Vector3.ZERO

const default_acceleration = 12
const air_acceleration = 1
var current_acceleration = default_acceleration


const gravity = 9.8
var gravity_vec = Vector3()

onready var camera = get_node("Camera")

func _input(event):
	# InputEventMouseMotion with Eulate_Mouce_from_Toutch does not give you multi touch support thats usable; use InputEventScreenToutch.
	# we are using this bit of code to get the reletive mouse motion,
	# and then we rotate the camera and the player using that motion.
	# hear We need to use InputEventScreenDrag. not using InputEventScreenDrag will result in bugs
	# InputEventMouseMotion doesn't work well
	
	if (event is InputEventScreenDrag ):
		rotate_y((event.relative.x) * drag_sensitivity)
		camera.rotate_x((event.relative.y * (drag_sensitivity ) * invert_screen_drag))
		camera.rotation.x = clamp(camera.rotation.x,-1.55,1.55)
	
func _physics_process(delta):
	_gyro()
	# basic movement 
	var h_rot:float = global_transform.basis.get_euler().y
	var d:Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	player_direction = (Vector3(d.x, 0, d.y).rotated(Vector3.UP, h_rot))
	
	if is_on_floor():
		snap = -get_floor_normal()
		current_acceleration = default_acceleration
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		current_acceleration = air_acceleration
		gravity_vec += Vector3.DOWN * gravity * delta
	if Input.is_action_just_pressed("ui_select") && is_on_floor():
		snap = Vector3.ZERO
		velocity.y = 10
	velocity = velocity.linear_interpolate(player_direction * speed, current_acceleration * delta)
	movement = velocity + gravity_vec 
	move_and_slide_with_snap(movement, snap, Vector3.UP)
func _gyro():
	# As of 2024, this is standard in all FPS games. PUBG, CoDM, etc., you need this. 100%
	gyroscope = Input.get_gyroscope()
	rotate_y((gyroscope.y ) * -(gyro_sensitivity))
	camera.rotate_x((gyroscope.x * (gyro_sensitivity) * -invert_gyro))
	camera.rotation.x = clamp(camera.rotation.x,-1.55,1.55)


#All UI buttons in Godot right now do not have multi-touch.
#Because you need to use mouse emulation, you do not get proper multitutoutch support.
#Right now, Emoulate Mouse from Toutch is on in project settings, but I'm not using it for that reason.
#I used texture rects instead and connected gui_input (event) to my player.
# If the event is InputEventScreenTouch, we fire the gun, jump, or reload.
#This is far from perfect, but it should give you an idea of what you need to do.
# Special thanks to Marco Fazio for the joystack MIT.
func _on_fire_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			$Camera/gun/AnimationPlayer.play("fire")
func _on_jump_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			Input.action_press("ui_select")
func _on_reload_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			$Camera/gun/AnimationPlayer.play("reload")
