extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	if Input.is_action_pressed("toggle_lights"):
		rotate_y(deg2rad(15))
	if Input.is_action_pressed("accelerate"):
		translation.z += 0.1
		pass
	if Input.is_action_pressed("decelerate"):
		translation.z -= 0.1
		pass
	if Input.is_action_pressed("turn_left"):
		translation.x += 0.1
		pass
	if Input.is_action_pressed("turn_right"):
		translation.x -= 0.1
		pass
	if Input.is_action_pressed("indicate_left"):
		translation.y += 0.1
		pass
	if Input.is_action_pressed("indicate_right"):
		translation.y -= 0.1
		pass
	pass
