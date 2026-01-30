extends Node2D

## CURSOR
@onready var cursor_node = $cursor
@onready var HAND = $cursor/AnimatedSprite2D
@onready var hand_collider = $cursor/collision

## VICTIMS
@onready var david = $world/base

## WORLD
@onready var david_scene = preload("res://scenes/victim_main.tscn")

var man_is_angry = false

var SCREENSIZE : Vector2i
var tick : float = 0.0
var rand : float = 2.0

func _ready():
	HAND.play("open_hand")
	david.region_enabled = true
	david.region_rect = Rect2(0,0,512,512)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	SCREENSIZE = get_viewport().size
	cursor_node.position = SCREENSIZE/2

func _unhandled_input(event):
	## LOCK CURSOR TO THE MOUSE POSITION
	if event is InputEventMouseMotion:
		cursor_node.global_position = event.position

func _process(delta):
	## IF YOU LOSE, THIS IS ACTIVATED TO MAKE THE GUY RUN AT YOU BEFORE THE GAME KILLS ITSELF
	if man_is_angry:
		david.position += Vector2(0,8)
		david.scale += Vector2(0.05,0.05)
		if david.scale.x >= 3: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_parent().queue_free()
		return
	
	## MAKE THE GUY MOVE AROUND A LITTLE
	tick += delta
	if tick >= rand:
		tick = 0.0
		rand = randf_range(1,3)
		var sprite = randi_range(0,2) * 512
		david.region_rect = Rect2(sprite,0,512,512)
		david.position += Vector2(randi_range(-16,16),randi_range(-16,16))
	
	## ANIMATE THE HAND TO POINT AT THE VICTIM ON HOVER
	if hand_collider.overlaps_area(david.get_child(0)):
		david.modulate = Color.LIGHT_BLUE
		HAND.play("point_forward")
		if Input.is_action_just_pressed("grab"):
			var new_victim = david_scene.instantiate()
			self.get_parent().add_child(new_victim)
			self.queue_free()
	else: 
		david.modulate = Color.WHITE
		HAND.play("open_hand")

## THIS FUNCTION IS CALLED FROM THE VICTIM SCENE IF YOU FAIL
func angry_man():
	man_is_angry = true
	
	david.position = SCREENSIZE/2
	david.region_rect = Rect2(1536,0,512,512)
