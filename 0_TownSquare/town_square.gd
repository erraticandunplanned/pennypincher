extends Node2D
class_name TownSquareNode
# ========= #
# variables #
# ========= #
@onready var Camera: Camera2D = $Camera
@onready var UI    : UINode   = $Camera/CanvasLayer/Ui
var Difficulty     : float    = 0.0:
	set(new_val): if new_val >= 0.0: Difficulty     = new_val
var PinchedPennies : float    = 0.0:
	set(new_val): if new_val >= 0.0: PinchedPennies = new_val
var Victim         : VictimNode:
	set(new_node):
		if Victim or not new_node:
			print("clearing victim") 
			Victim.queue_free()
			remove_child(Victim)
		Victim = new_node
		Victim.set_name("victim_" + str(randi()))
		Victim.finished.connect(_on_victim_finished)
		Victim.pilfered.connect(_on_victim_pilfered)
		add_child(Victim)
# ================ #
# signal reception #
# ================ #
func _on_ui_new_game_button_pressed()    -> void:
	UI._change_visibility(false)
	new_victim()
func _on_ui_high_scores_button_pressed() -> void: 
	print("high_scores_button_pressed")
func _on_victim_finished(Caught: bool)   -> void:
	if Caught:
		UI._change_visibility(true)
		UI._add_highscore(PinchedPennies, "John Stickyfingers")
		PinchedPennies = 0.0
		Difficulty = 0.0
		Victim = null
	else:
		new_victim()
func _on_victim_pilfered(Value: float)   -> void:
	PinchedPennies += Value
# ================ #
# internal utility #
# ================ #
func new_victim() -> void:
	Victim = VictimNode.new(0.0)
