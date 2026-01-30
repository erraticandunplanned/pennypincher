extends Node2D

@onready var cursor_node = $cursor
@onready var held_item = $cursor/held_item
@onready var world_node = $world
@onready var objects_node = $world/objects
@onready var HAND = $cursor/AnimatedSprite2D

var SCREENSIZE : Vector2i
var move_threshold = 640
var ext_border = 64
var world_scroll_speed = 500

var previous_curser_pos : Vector2

func _ready():
	HAND.play("open_hand")
	## PLACE CURSOR IN THE CENTRE OF THE SCREEN
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	SCREENSIZE = get_viewport().size
	cursor_node.position = SCREENSIZE/2
	previous_curser_pos = cursor_node.position

func _unhandled_input(event):
	## LOCK CURSOR TO THE MOUSE POSITION
	if event is InputEventMouseMotion:
		cursor_node.global_position = event.position

func _process(delta):
	## MAKE THE MOUSE VISIBLE IF IT IS OUTSIDE THE "BORDER"
	## this keeps the user from dragging the mouse all the way outside of the window
	if cursor_node.position.x < (SCREENSIZE.x - ext_border) and cursor_node.position.y < (SCREENSIZE.y - ext_border) and cursor_node.position.x > ext_border and cursor_node.position.y > ext_border:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	## DETERMINE HOW MUCH TO MOVE THE WORLD BY                                                                                                                        EXAMPLE FROM THE FIRST IF-STATEMENT
	## this is done by first determining if the cursor is close enough to an edge ("close enough" == within move_threshold pixels of the window's edge)               (cursor_node.position.x + move_threshold - SCREENSIZE.x)
	## and then, crunch the values between zero and one, such that the curser *just* on the edge of the border is 0, and all the way at the edge of the screen is 1   / (move_threshold-ext_border)
	## and then raise it to the power of 4 so it is an exponential scaling the closer you get to the edge of the screen                                               **4
	## and then multiply the value by _delta and world_scroll_speed                                                                                                   delta * world_scroll_speed
	var world_move_vector = Vector2.ZERO
	if cursor_node.position.x > ( SCREENSIZE.x - move_threshold ):
		world_move_vector.x -= delta * world_scroll_speed * (((cursor_node.position.x + move_threshold - SCREENSIZE.x) / (move_threshold-ext_border))**4)
	if cursor_node.position.x < move_threshold:
		world_move_vector.x += delta * world_scroll_speed * ((abs(move_threshold - cursor_node.position.x) / (move_threshold-ext_border))**4)
	if cursor_node.position.y > ( SCREENSIZE.y - move_threshold ):
		world_move_vector.y -= delta * world_scroll_speed * (((cursor_node.position.y + move_threshold - SCREENSIZE.y) / (move_threshold-ext_border))**4)
	if cursor_node.position.y < move_threshold:
		world_move_vector.y += delta * world_scroll_speed * ((abs(move_threshold - cursor_node.position.y) / (move_threshold-ext_border))**4)
	
	## MOVE THE WORLD
	world_node.position += world_move_vector
	
	## ANIMATE GRAB HAND ON CLICK
	if Input.is_action_just_pressed("grab"):
		HAND.play("closed_hand")
	if Input.is_action_just_released("grab"):
		HAND.play("open_hand")
	
	## PICK UP OBJECTS ON CLICK
	if Input.is_action_just_pressed("grab"):
		for i in objects_node.get_children():
			if cursor_node.position.distance_to(i.position+world_node.position) < 48:
				objects_node.remove_child(i)
				held_item.add_child(i)
				i.position = Vector2.ZERO
	if Input.is_action_just_released("grab"):
		for i in held_item.get_children():
			held_item.remove_child(i)
			objects_node.add_child(i)
			i.position = cursor_node.position - world_node.position
