extends Control

var is_alive : int = 0
var pos : Vector2 = Vector2()
onready var anim = get_node("AnimationPlayer")


func initialize_cell(position : Vector2):
	pos = position

func set_status(status : int):
	is_alive = status
	
	if (is_alive == 1):
		anim.play("Living")
	else:
		anim.play("Dead")

func get_status():
	return is_alive
	
func get_location():
	return pos
