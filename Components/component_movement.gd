class_name Component_Movement extends Node3D

@onready var object: Node = get_parent()
@onready var timer: Timer = $Timer

@onready var piece: PackedScene = Main_Scene.ref.piece

var top_piece: Node3D

const FALL_SPEED: float = .4
var falling: bool = true

const MOVE_SPEED_HORIZ: float = 1.
const BUTTON_HOLD_DELAY: float = .1
var moving_left: bool = false
var moving_right: bool = false

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

func _input(event) -> void:
	if(event is InputEventKey and event.is_pressed()): #Ensure a key is pressed
		rotational_movement(event)
		horizontal_movement(event)
	
func rotational_movement(event) -> void:
	get_current_bottom_piece_pos()
	if Input.is_action_just_pressed("Button 1"):
		match rotate_position:
			rotate_positions.TOP:
				top_piece.position = top_offset_left
				rotate_position = rotate_positions.LEFT
			rotate_positions.LEFT:
				top_piece.position = top_offset_bottom
				rotate_position = rotate_positions.BOTTOM
			rotate_positions.BOTTOM:
				top_piece.position = top_offset_right
				rotate_position = rotate_positions.RIGHT
			rotate_positions.RIGHT:
				top_piece.position = top_offset_top
				rotate_position = rotate_positions.TOP
				
	if Input.is_action_just_pressed("Button 2"):
		match rotate_position:
			rotate_positions.TOP:
				top_piece.position = top_offset_right
				rotate_position = rotate_positions.RIGHT
			rotate_positions.RIGHT:
				top_piece.position = top_offset_bottom
				rotate_position = rotate_positions.BOTTOM
			rotate_positions.BOTTOM:
				top_piece.position = top_offset_left
				rotate_position = rotate_positions.LEFT
			rotate_positions.LEFT:
				top_piece.position = top_offset_top
				rotate_position = rotate_positions.TOP
		
		
func get_current_bottom_piece_pos() -> void:
	top_offset_top = Vector3(position.x,1.,position.z)
	top_offset_left = Vector3(-1.,position.y,position.z)
	top_offset_bottom = Vector3(position.x,-1.,position.z)
	top_offset_right = Vector3(1.,position.y,position.z)		

func horizontal_movement(event) -> void:
	if(Input.is_action_pressed("Left") and not moving_left):
		moving_left=true
		while(true):
			if(not Input.is_action_pressed("Left")):break
			object.position.x -= MOVE_SPEED_HORIZ
			await get_tree().create_timer(BUTTON_HOLD_DELAY).timeout
		moving_left=false
	
	if(Input.is_action_pressed("Right") and not moving_right):
		moving_right=true
		while(true):
			if(not Input.is_action_pressed("Right")):break
			object.position.x += MOVE_SPEED_HORIZ
			await get_tree().create_timer(BUTTON_HOLD_DELAY).timeout
		moving_right=false
	
func _on_timeout():
	if falling:
		object.position.y -= FALL_SPEED
	else:
		timer.stop()
		
enum walled_state {NEITHER,LEFT,RIGHT}

func _process(_delta: float) -> void:
	if is_on_floor():
		#grounded.emit()
		pass
		
	check_sides()
	
func check_sides() -> void:
	#match has_piece_nearby():
		
	#match detected_walled_state():
		#walled_state.NEITHER:
			#unblocked_left.emit(true)
			#unblocked_right.emit(true)
		#walled_state.LEFT:
			#blocked_left.emit(true)
			#unblocked_right.emit(true)
		#walled_state.RIGHT:
			#blocked_right.emit(true)
			#unblocked_left.emit(true)
	pass
		
func is_on_floor() -> bool:
	return is_equal_approx(position.y,Globals.GROUND_POS)

func detected_walled_state() -> walled_state:
	if is_equal_approx(position.x,Globals.WALL_L_POS):
		return walled_state.LEFT
	elif is_equal_approx(position.x,Globals.WALL_R_POS):
		return walled_state.RIGHT
	else:
		return walled_state.NEITHER
	
	
	
