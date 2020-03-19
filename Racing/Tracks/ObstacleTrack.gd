extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal end_reached

export (PackedScene) var skybox
export (PackedScene) var track_piece
export (PackedScene) var obstacle

export (int) var track_length
var track_traversed = 0

var elapsed_time = 0.0
var race_over = false

const piece_length = 12
const pieces_amount = 48
const track_start = ((piece_length / 2) * pieces_amount)

var pieces = []
var front_spawners = []

var spawn_chance = 0.2

func _ready():
	track_length = max(track_length, 50)

	$Player.set_skybox(skybox)

	for i in range(pieces_amount):
		var piece = track_piece.instance()
		piece.translation.z = track_start - (i * piece_length)
		pieces.append(piece)
		add_child(piece)
	# Create tracks in front of and behind car
	front_spawners = $Statics/FrontSpawners.get_children()

	set_process(true)
	pass

func compute_score(elapsed_time):
	var max_score = 100_000
	var diff = abs(0 - elapsed_time)
	return pow(2, -diff) * max_score

func save_score(time):
	var f = File.new()
	f.open_encrypted_with_pass("user://best.time", File.READ, OS.get_unique_id())
	if f.get_line().to_float() < time:	
		f.close()
		f.open_encrypted_with_pass("user://best.time", File.WRITE, OS.get_unique_id())
		f.store_string("%f" % elapsed_time)
		f.close()
	else:
		f.close()

func _process(delta):
	elapsed_time += delta
	$Player/GUI/TimerPanel/Timer.text = "%06.2f" % elapsed_time
	if !race_over and track_traversed >= track_length:
		print("gz, you ran the obstacle course in: ", elapsed_time, " seconds!")
		race_over = true
		save_score(elapsed_time)
		get_tree().change_scene("res://Menu.tscn")
	if Input.is_key_pressed(KEY_ESCAPE):
		race_over = true
		get_tree().change_scene("res://Menu.tscn")
	pass

func _restructure_track():

	track_traversed += 1

	$Statics.translation.z = $Statics.translation.z - (piece_length * 4)

	var current_z_translation = pieces.back().translation.z - (piece_length)

	var piece1 = pieces.pop_front()
	var piece2 = pieces.pop_front()
	var piece3 = pieces.pop_front()
	var piece4 = pieces.pop_front()

	piece1.translation.z = pieces.back().translation.z - (piece_length)
	piece2.translation.z = piece1.translation.z - piece_length
	piece3.translation.z = piece2.translation.z - piece_length
	piece4.translation.z = piece3.translation.z - piece_length

	pieces.push_back(piece1)
	pieces.push_back(piece2)
	pieces.push_back(piece3)
	pieces.push_back(piece4)
	pass

func _spawn_obstacle():
	var progress = float(float(track_traversed) / float(track_length))
	var amount = min(1 + int((progress * 4)) , 3) #min, because we want a maximum of 3.
	print("spawning: ", amount)
	var spawner_ids = [0, 1, 2, 3]
	for spawn in range(amount):
		var choice = randf()
		if choice > spawn_chance + progress:
			print("\t\tchoice was: ", choice, ", spawn_chance: ", spawn_chance, ", progress: ", progress)
			return
		var obs_instance = obstacle.instance()
		self.add_child(obs_instance)
		var spawner_id = randi() % spawner_ids.size()
		print("\tspawning ", spawn + 1, "/", amount, " at positon: ", spawner_id)
		var spawner = front_spawners[spawner_ids[spawner_id]]
		spawner_ids.remove(spawner_id)
		var final_translation = Vector3() #Annoyingly, we have to add the transformations together...
		final_translation += $Statics.translation
		final_translation += $Statics/FrontSpawners.translation
		final_translation += spawner.translation
		obs_instance.translation = final_translation
		# At least we don't have to multiply them ;P
	pass

func _on_Player_collided(object):
	if object == $Statics/RestructureTrigger:
		print(Engine.get_frames_per_second(), "\t", "progress: ", track_traversed, "/", track_length)
		_restructure_track()
		_spawn_obstacle()
	pass # replace with function body
