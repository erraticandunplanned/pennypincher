extends Control
class_name UINode
# ========= #
# variables #
# ========= #
signal new_game_button_pressed
signal high_scores_button_pressed
var HighScores: Dictionary = {}
# =============== #
# signal emission #
# =============== #
func _on_new_game_button_pressed()    -> void: new_game_button_pressed.emit()
func _on_high_scores_button_pressed() -> void: high_scores_button_pressed.emit()
# ============== #
# call reception #
# ============== #
func _change_visibility(Visible: bool) -> void:
	set_visible(Visible)
func _add_highscore(PennyCount: float, Name: String) -> void:
	HighScores[Name] = PennyCount
