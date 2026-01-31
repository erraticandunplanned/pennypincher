extends Node2D
class_name VictimNode
# ========= #
# variables #
# ========= #
signal finished(Caught: bool)
signal pilfered(Value: float)
# ================ #
# internal utility #
# ================ #
func _init(_Difficulty: float) -> void:
	var img = Sprite2D.new()
	img.set_name("image")
	img.set_texture(load("res://2_Victim/textures/pilferable_guy.jpg"))
	add_child(img)
