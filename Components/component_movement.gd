class_name Component_Movement extends Node3D

@onready var object: Node = get_parent()
@onready var timer: Timer = $Timer

@onready var piece: PackedScene = Main_Scene.ref.piece

var top_piece: Node3D

const FALL_SPEED: float = .4
var falling: bool = true

var walled_state: walled_states
enum walled_states {NEITHER,LEFT,RIGHT}

const MOVE_SPEED_HORIZ: float = 1.
const BUTTON_HOLD_DELAY: float = .1
var moving_left: bool = false
var moving_right: bool = false
var moving_down: bool = false

var downward_movement_allowed: bool = true

const MOVE_SPEED_ROTATE: float = .3
var rotate_position: rotate_positions
enum rotate_positions {TOP,RIGHT,BOTTOM,LEFT}

var top_offset_top: Vector3
var top_offset_left: Vector3
var top_offset_bottom: Vector3
var top_offset_right: Vector3

var has_wall_on_right: bool = false
var has_wall_on_left: bool = false

var has_piece_on_right: bool = false
var has_piece_on_left: bool = false
var has_piece_on_down: bool = false

func _ready() -> void:
	var piece_to_add: Node3D = piece.instantiate()
	top_piece = piece_to_add
	
	add_child(top_piece)
	top_piece.position.y += 1.
	
	timer.timeout.connect(_on_timeout)
	timer.start(.5)
	
	%Area_Main.area_entered.connect(_on_area_main_entered)
	%Area_Main.area_exited.connect(_on_area_main_exited)
	
	%Area_Bottom.area_entered.connect(_on_area_bottom_entered)

func _input(event) -> void:
	if(event is InputEventKey and event.is_pressed()): #Ensure a key is pressed
		rotational_movement()
		directional_movement()
	
func _on_timeout():
	if falling:
		object.position.y -= FALL_SPEED
	else:
		timer.stop()
		
func rotational_movement() -> void:
	get_current_bottom_piece_pos()
	if Input.is_action_just_pressed("Button 1"):
		match rotate_position:
			rotate_positions.TOP:
				rotate_piece(top_offset_left,rotate_positions.LEFT)
			rotate_positions.LEFT:
				rotate_piece(top_offset_bottom,rotate_positions.BOTTOM)
			rotate_positions.BOTTOM:
				rotate_piece(top_offset_right,rotate_positions.RIGHT)
			rotate_positions.RIGHT:
				rotate_piece(top_offset_top,rotate_positions.TOP)
				
	if Input.is_action_just_pressed("Button 2"):
		match rotate_position:
			rotate_positions.TOP:
				rotate_piece(top_offset_right,rotate_positions.RIGHT)
			rotate_positions.RIGHT:
				rotate_piece(top_offset_bottom,rotate_positions.BOTTOM)
			rotate_positions.BOTTOM:
				rotate_piece(top_offset_left,rotate_positions.LEFT)
			rotate_positions.LEFT:
				rotate_piece(top_offset_top,rotate_positions.TOP)
		
func get_current_bottom_piece_pos() -> void:
	top_offset_top = Vector3(position.x,1.,position.z)
	top_offset_left = Vector3(-1.,position.y,position.z)
	top_offset_bottom = Vector3(position.x,-1.,position.z)
	top_offset_right = Vector3(1.,position.y,position.z)
	
func rotate_piece(direction: Vector3,new_position: rotate_positions):
	var tween: Tween = %RotationTweens.create_tween()	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(top_piece, "position", direction, MOVE_SPEED_ROTATE)
	rotate_position = new_position

func directional_movement() -> void:
	if falling:
		if not walled_state == walled_states.LEFT:
			if(Input.is_action_pressed("Left") and not moving_left):
				moving_left=true
				while(true):
					if(not Input.is_action_pressed("Left") or walled_state == walled_states.LEFT or not downward_movement_allowed):break
					object.position.x -= MOVE_SPEED_HORIZ
					await get_tree().create_timer(BUTTON_HOLD_DELAY).timeout
				moving_left=false
		
		if not walled_state == walled_states.RIGHT:
			if(Input.is_action_pressed("Right") and not moving_right):
				moving_right=true
				while(true):
					if(not Input.is_action_pressed("Right") or walled_state == walled_states.RIGHT or not downward_movement_allowed):break
					object.position.x += MOVE_SPEED_HORIZ
					await get_tree().create_timer(BUTTON_HOLD_DELAY).timeout
				moving_right=false
			
		if(Input.is_action_pressed("Down") and not moving_down) and downward_movement_allowed:
			moving_down = true
			while(true):
				if(not Input.is_action_pressed("Down") or not falling or not downward_movement_allowed): break
				
				object.position.y -= FALL_SPEED
				#var tween: Tween = %DownwardTweens.create_tween()	
				#tween.set_ease(Tween.EASE_OUT)
				#tween.tween_property(object, "position:y", downward_fall_speed, .1)
				
				await get_tree().create_timer(BUTTON_HOLD_DELAY/25).timeout
			moving_down = false
	
	
func _on_area_main_entered(area) -> void:
	match area.name:
		"Ground":
			falling = false
		"Wall_L":
			walled_state = walled_states.LEFT
		"Wall_R":
			walled_state = walled_states.RIGHT
		_:
			pass

func _on_area_main_exited(area) -> void:
	match area.name:
		"Wall_L":
			walled_state = walled_states.NEITHER
		"Wall_R":
			walled_state = walled_states.NEITHER
		_:
			pass
			
func _on_area_bottom_entered(area) -> void:
	if area.name == "Ground":
		print("you are setting it up correctly")
		downward_movement_allowed = false
