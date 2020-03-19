extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var exploded = false
var z_velocity = 0.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	if exploded:
		self.translation.z -= z_velocity * delta
		if !$Particles.emitting:
			queue_free()
			pass
		pass
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass


func _on_Roadblock_area_entered(area):
	if area.is_in_group("Player"):
		var player = area.get_player()
		z_velocity = player.power
		$MeshInstance.visible = false
		$Particles.emitting = true
		exploded = true
		pass
	pass # replace with function body

func _on_VisibilityNotifier_screen_exited():
	queue_free()
	pass # replace with function body
