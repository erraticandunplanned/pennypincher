extends Node2D

## CURSOR
@onready var cursor_node = $cursor
@onready var HAND = $cursor/AnimatedSprite2D
@onready var hand_collider = $cursor/collision
@onready var warning_collider = $cursor/warning_collider
@onready var warning_light = $cursor/warning_light
@onready var held_item = $cursor/held_item
## WORLD
@onready var world_node = $world
@onready var objects_node = $world/objects
@onready var pocket_image = $world/pocket
@onready var doorway = $world/zones/doorway
@onready var inside_zone = $world/zones/inside_da_pocket
@onready var upper_lip = $world/zones/upper_pocket
@onready var lower_lip = $world/zones/lower_pocket
@onready var leave_zone = $world/zones/leave

var SCREENSIZE : Vector2i
var move_threshold = 640
var ext_border = 64
var world_scroll_speed = 500

var over_the_pocket = false
var at_the_entrance = false
var inside_the_pocket = false

var hit_timer = 0.0

func _ready():
	HAND.play("open_hand")
	## PLACE CURSOR IN THE CENTRE OF THE SCREEN
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	SCREENSIZE = get_viewport().size
	cursor_node.position = SCREENSIZE/2

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
	
	## DETERMINE HOW MUCH TO MOVE THE WORLD BY
	## this is done by first determining if the cursor is close enough to an edge ("close enough" == within move_threshold pixels of the window's edge)
	## and then, crunch the values between zero and one, such that the curser *just* on the edge of the border is 0, and all the way at the edge of the screen is 1
	## and then raise it to the power of 4 so it is an exponential scaling the closer you get to the edge of the screen
	## and then multiply the value by _delta and world_scroll_speed
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
	
	## ANIMATE HAND
	if Input.is_action_just_pressed("grab"):
		HAND.play("closed_hand")
	if Input.is_action_just_released("grab"):
		HAND.play("open_hand")
	if hand_collider.overlaps_area(leave_zone) and not Input.is_action_pressed("grab"): HAND.play("thumb_back")
	if HAND.animation == "thumb_back" and not hand_collider.overlaps_area(leave_zone): HAND.play("open_hand")
	
	## PICK UP OBJECTS ON CLICK
	if Input.is_action_just_pressed("grab"):
		for i in objects_node.get_children():
			if cursor_node.position.distance_to(i.position+world_node.position) < 48:
				objects_node.remove_child(i)
				held_item.add_child(i)
				i.position = Vector2.ZERO
				i.z_index = -1
	if Input.is_action_just_released("grab"):
		for i in held_item.get_children():
			held_item.remove_child(i)
			objects_node.add_child(i)
			i.position = cursor_node.position - world_node.position
			i.z_index = cursor_node.z_index
	
	## THE HAND DOESN'T INTERACT WITH ZAP ZONES IF IT IS "ON TOP OF" THE POCKET INSTEAD OF INSIDE IT
	if not hand_collider.overlaps_area(doorway) and not hand_collider.overlaps_area(inside_zone):
		over_the_pocket = false
		inside_the_pocket = false
		at_the_entrance = false
		cursor_node.z_index = 3
	if hand_collider.overlaps_area(inside_zone) and not at_the_entrance:
		over_the_pocket = true
	
	## SNEAK INTO DA POCKET
	if hand_collider.overlaps_area(doorway) and not over_the_pocket:
		at_the_entrance = true
		cursor_node.z_index = 1
	if hand_collider.overlaps_area(inside_zone) and at_the_entrance:
		inside_the_pocket = true
	
	
	## FLASH THE WARNING LIGHTS IF YOU GET TO CLOSE TO A ZAP ZONE
	if at_the_entrance and (warning_collider.overlaps_area(upper_lip) or warning_collider.overlaps_area(lower_lip)):
		warning_light.visible = not warning_light.visible
	else:
		warning_light.visible = false
		HAND.modulate = Color.WHITE
	
	## FLASH THE HAND IF YOU COLLIDE WITH ZAPZONES
	if at_the_entrance and ( hand_collider.overlaps_area(upper_lip) or hand_collider.overlaps_area(lower_lip)):
		if warning_light.visible:
			HAND.modulate = Color.RED
		else:
			HAND.modulate = Color.WHITE
		hit_timer += delta
	else:
		HAND.modulate = Color.WHITE
	
	## LOSE THE GAME IF YOU HIT TOO MANY ZAP ZONES
	if hit_timer >= 1.0:
		get_parent().return_to_victims()
		get_parent().man_is_angry()
		self.queue_free()
	
	## LEAVE THE VICTEM AND MOVE ON TO ANOTHER
	if hand_collider.overlaps_area(leave_zone) and Input.is_action_just_pressed("grab"):
		get_parent().return_to_victims()
		self.queue_free()
