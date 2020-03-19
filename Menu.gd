extends CanvasLayer

signal start_game

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func read_highscore():
	var f = File.new()
	if not f.file_exists("user://best.time"):
		return
	f.open_encrypted_with_pass("user://best.time", File.READ, OS.get_unique_id())
	var line = f.get_line()
	$Panel/HighScore.text = "Best Time: " + line
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Play.grab_focus()
	read_highscore()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delta >= 10:
		read_highscore()
	pass


func _on_Github_pressed():
	OS.shell_open("https://github.com/ContainedBlargh")
	pass # Replace with function body.


func _on_Wingcorp_pressed():
	OS.shell_open("https://wingcorp.eu")
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_Play_pressed():
	get_tree().change_scene("res://Racing/Tracks/ObstacleTrack.tscn")
	pass # Replace with function body.
