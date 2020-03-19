extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var driving_lights
var indicating_left
var indicating_right

func _ready():
	turn_on_driving_lights()
	indicating_left = false
	indicating_right = false
	set_process(true)
	pass

func toggle_driving_lights():
	driving_lights = !driving_lights
	$LeftHeadlight.visible = driving_lights
	$LeftHeadlightOmni.visible = driving_lights
	$RightHeadlight.visible = driving_lights
	$RightHeadlightOmni.visible = driving_lights
	$LeftRearLight.visible = driving_lights
	$RightRearLight.visible = driving_lights
	pass

func turn_off_driving_lights():
	driving_lights = false
	$LeftHeadlight.visible = driving_lights
	$LeftHeadlightOmni.visible = driving_lights
	$RightHeadlight.visible = driving_lights
	$RightHeadlightOmni.visible = driving_lights
	$LeftRearLight.visible = driving_lights
	$RightRearLight.visible = driving_lights

func turn_on_driving_lights():
	driving_lights = true
	$LeftHeadlight.visible = driving_lights
	$LeftHeadlightOmni.visible = driving_lights
	$RightHeadlight.visible = driving_lights
	$RightHeadlightOmni.visible = driving_lights
	$LeftRearLight.visible = driving_lights
	$RightRearLight.visible = driving_lights

func enable_brake_lights():
	$LeftBrakeLight.visible = true
	$RightBrakeLight.visible = true
	pass

func disable_brake_lights():
	$LeftBrakeLight.visible = false
	$RightBrakeLight.visible = false
	pass
	
#This function ought to be private, but that is not happening in godotscript :/
func _toggle_left_indicators():
	$LeftFrontIndicator.visible = !$LeftFrontIndicator.visible
	$LeftRearIndicator.visible = !$LeftRearIndicator.visible
	pass
	
func _toggle_right_indicators():
	$RightFrontIndicator.visible = !$RightFrontIndicator.visible
	$RightRearIndicator.visible = !$RightRearIndicator.visible
	pass

func indicate_left():
	indicating_right = false

	indicating_left = !indicating_left
	pass

func indicate_right():
	indicating_left = false
	indicating_right = !indicating_right
	pass

func _on_IndicatorTimer_timeout():
	if(indicating_left or indicating_right):
		if (indicating_left):
			_toggle_left_indicators()
		else:
			_toggle_right_indicators()
		$IndicatorTimer.start()
	pass # replace with function body


func _process(delta):
	if $IndicatorTimer.is_stopped() and (indicating_left or indicating_right):
		$IndicatorTimer.start()
	if !indicating_left:
		$LeftFrontIndicator.visible = false
		$LeftRearIndicator.visible = false
	if !indicating_right:
		$RightFrontIndicator.visible = false
		$RightRearIndicator.visible = false
	pass

