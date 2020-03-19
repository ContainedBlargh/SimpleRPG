extends Spatial

var power = 0.0 # Current forward movement of player.

const max_power = 35.0
const squeal_limit = max_power / 2
const power_delta = 0.01

const orientation = -90.0

signal collided(object)

var changing_speed = false

var colliding_left = false
var colliding_right = false

var turning_left = false
var turning_right = false

var light_system = null

# Takes a packed scene acting as the skybox
func set_skybox(skybox):
	for child in $SkyboxContainer.get_children():
		$SkyboxContainer.remove_child(child)
		child.queue_free()
	var instance = skybox.instance()
	$SkyboxContainer.add_child(instance)
	pass

func _ready():
	light_system = $CarMesh/LightSystem
	set_process(true)
	pass

func stop_squeal_front_tires():
	$CarMesh/LeftTireSmoke2.emitting = false
	$CarMesh/RightTireSmoke2.emitting = false

func squeal_front_tires():
	if (!$CarMesh/RightTireSmoke2.emitting):
		$CarMesh/RightTireSmoke2.restart()
	if (!$CarMesh/LeftTireSmoke2.emitting):
		$CarMesh/LeftTireSmoke2.restart()
	pass

func stop_squeal_rear_tires():
	$CarMesh/LeftTireSmoke.emitting = false
	$CarMesh/RightTireSmoke.emitting = false

func squeal_rear_tires():
	if (!$CarMesh/RightTireSmoke.emitting):
		$CarMesh/RightTireSmoke.restart()
	if (!$CarMesh/LeftTireSmoke.emitting):
		$CarMesh/LeftTireSmoke.restart()
	pass

func accelerate():
	if power < squeal_limit / 8:
		power += (max_power) * (power_delta * 0.3)
		squeal_rear_tires()
	elif power < squeal_limit:
		power += (max_power) * (power_delta * 1.2)
		squeal_rear_tires()
	elif power < max_power:
		power += (max_power) * power_delta
		if power > max_power:
			power = max_power
	pass
	
func decelerate():
	if power > squeal_limit:
		squeal_rear_tires()
	if power > 0:
		power -= ((max_power) * power_delta * 2)
	if power <= 0:
		power = 0.0
	pass

func handle_input():
	changing_speed = false
	if (Input.is_action_pressed("accelerate")):
		accelerate()
		changing_speed = true
	
	if (Input.is_action_pressed("decelerate")):
		decelerate()
		light_system.enable_brake_lights()
		changing_speed = true
	else:
		light_system.disable_brake_lights()
	
	if not changing_speed and power >= 0.125:
		power = min(power - max_power * power_delta, max_power * 0.9)
	
	if (Input.is_action_pressed("turn_left")):
		turning_left = true
		turning_right = false
	elif (Input.is_action_pressed("turn_right")):
		turning_right = true
		turning_left = false
	else:
		turning_left = false
		turning_right = false
	
	if (turning_left or turning_right) and power >= 0.125:
		power = min(power - max_power * power_delta, max_power * 0.95)
	
	if (turning_left or turning_right) and changing_speed:
		squeal_front_tires()
	else:
		stop_squeal_front_tires()
	
	if (Input.is_action_just_pressed("indicate_left")):
		light_system.indicate_left()
		pass
	
	if (Input.is_action_just_pressed("indicate_right")):
		light_system.indicate_right()
		pass
	
	if (Input.is_action_just_pressed("toggle_lights")):
		light_system.toggle_driving_lights()
		pass
	pass

func update_collisions():
	var collisions = $CarMesh/HitDetector.get_overlapping_areas()
	colliding_left = false
	colliding_right = false
	for area in collisions:
		if area.is_in_group("LeftWall"):
			colliding_left = true
		if area.is_in_group("RightWall"):
			colliding_right = true
	pass
	
func update_rotation():
	var rotation = rad2deg($CarMesh.rotation.y)
	var rot_delta = 15 - (7.5 * (power / max_power))
	if power > max_power / 10:
		if turning_left:
			$CarMesh.rotation.y = deg2rad(orientation + rot_delta)
		elif turning_right:
			$CarMesh.rotation.y = deg2rad(orientation - rot_delta)
		else:
			$CarMesh.rotation.y = deg2rad(orientation)

func update_position(delta):
	if colliding_left || colliding_right:
		if colliding_left:
			$CarMesh/LeftSparks.restart()
		if colliding_right:
			$CarMesh/RightSparks.restart()
		power = min(power, max_power * 0.25)

	var z_modifier = (power * delta)
	translation.z -= z_modifier
	var turn_modifier = ((power * 0.4) * delta)
	if changing_speed:
		turn_modifier = ((power * 0.32) * delta)
	if turning_left and !colliding_left:
		translation.x -= ((power * 0.4) * delta)
	elif turning_right and !colliding_right:
		translation.x += ((power * 0.4) * delta)

	# Update skybox position
	$SkyboxContainer.translation.z += z_modifier * 0.01

	pass

func _process(delta):
	handle_input()
	update_collisions()
	update_rotation()
	update_position(delta)
	pass

func _on_HitDetector_area_entered(area):
	if area.is_in_group("Obstacles"):
		#We just hit an obstacle!
		power *= 0.3
		pass
	emit_signal("collided", area)
	pass
