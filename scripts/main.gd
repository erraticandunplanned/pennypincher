extends Node2D

@onready var select_victim = preload("res://scenes/select_victim.tscn")

func _ready():
	return_to_victims()



func return_to_victims():
	var i = select_victim.instantiate()
	add_child(i)

func man_is_angry():
	get_child(1).angry_man()
