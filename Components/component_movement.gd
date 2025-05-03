class_name Component_Movement extends Node3D

@onready var object: Node = get_parent()
@onready var timer_idle_move: Timer = $Timer_Idle_Move
@onready var timer_move_left_delay: Timer = $Timer_Move_Left_Delay
@onready var timer_move_right_delay: Timer = $Timer_Move_Right_Delay

@onready var piece: PackedScene = Main_Scene.ref.piece

@onready var component_movement: PackedScene = Main_Scene.ref.component_movement
var bottom_component_movement: Node3D
var top_component_movement: Node3D

var top_piece: Node3D
var bottom_piece: Node3D

const FALL_SPEED: float = .4
var falling: bool = true

var walled_state: walled_states
enum walled_states {NEITHER,LEFT,RIGHT}

const MOVE_SPEED_HORIZ: float = 1.
const BUTTON_HOLD_DELAY: float = .06
var moving_left: bool = false
var moving_right: bool = false
var moving_down: bool = false

var downward_movement_allowed: bool = true

const MOVE_SPEED_ROTATE: float = .1
var rotate_position: rotate_positions
enum rotate_positions {TOP,RIGHT,BOTTOM,LEFT}
var rotating: bool = false

var top_offset_top: Vector3
var top_offset_left: Vector3
var top_offset_bottom: Vector3
var top_offset_right: Vector3

var adjusting_boundary: bool = false

func _ready() -> void:
	if object.is_bottom_piece:
		configure_bottom_piece()
	else:
		configure_top_piece()
	
	%Area_Main.area_entered.connect(_on_area_main_entered)
	%Area_Main.area_exited.connect(_on_area_main_exited)
	%Area_Main_Cushion.area_entered.connect(_on_area_main_cushion_entered)
	
func configure_top_piece() -> void:
	bottom_piece = object.get_parent().object
	
	bottom_component_movement = object.get_parent()
	
func configure_bottom_piece() -> void:
	%Area_Bottom.queue_free()
	timer_move_left_delay.timeout.connect(_on_move_delay_left_timeout)
	timer_move_right_delay.timeout.connect(_on_move_delay_right_timeout)
	timer_idle_move.timeout.connect(_on_idle_move_timeout)
	timer_idle_move.start(.5)
	
	var piece_to_add: Node3D = piece.instantiate()
	top_piece = piece_to_add
	top_piece.is_bottom_piece = false
	
	add_child(top_piece)
	top_piece.position.y += 1.
	top_piece.get_child(0).set_material_override(Globals.debug_material_top_piece)

	var component_to_add: Node3D = component_movement.instantiate()
	top_component_movement = component_to_add
	top_piece.add_child(top_component_movement)

func _input(event) -> void:
	if object.is_bottom_piece:
		if(event is InputEventKey and event.is_pressed()): #Ensure a key is pressed
			directional_movement()
			#horizontal_movement(event)
			if not move_delay_timer_is_running():
				rotational_movement()

func _process(_delta: float) -> void:
	if not object.is_bottom_piece:
		check_top_rotation()
	#if object.is_bottom_piece:
		#check_boundary_break()
		#
#func check_boundary_break() -> void:
	#if object.position.x < 1. and not adjusting_boundary:
		#object.position.x = 1
		#
	#if object.position.x > 6 and not adjusting_boundary:
		#position.x = 1
		
		
func move_delay_timer_is_running() -> bool:
	return is_greater_approx(timer_move_left_delay.time_left,0.) or is_greater_approx(timer_move_right_delay.time_left,0.)
	
func is_greater_approx(a: float, b: float, tolerance: float = 0.1) -> bool:
	return a > b and (a - b) > tolerance

func check_top_rotation():
	if bottom_component_movement.rotating:
		for area in %Area_Bottom.get_overlapping_areas():
			match area.name:
				"Wall_L":
					bottom_piece.position.x += 1
					
				"Wall_R":
					bottom_piece.position.x -= 1
					
				"Ground":
					bottom_piece.position.y += 1
					
				_:
					pass
	
func _on_idle_move_timeout():
	if falling:
		object.position.y -= FALL_SPEED
	else:
		timer_idle_move.stop()
		
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
	var tween = %RotationTweens.create_tween()
	rotating = true
	#print("\rRotating is ",rotating)
	tween.finished.connect(_on_rotation_tween_finished)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(top_piece, "position", direction, MOVE_SPEED_ROTATE)
	rotate_position = new_position
	
func _on_rotation_tween_finished():
	rotating = false
	#print("Rotating is ",rotating,"\r")
	
func horizontal_movement(event) -> void:
	if falling and not event.is_echo():
		if not walled_state == walled_states.LEFT:
			object.position.x -= float(Input.is_action_pressed("Left"))
		if not walled_state == walled_states.RIGHT:
			object.position.x += float(Input.is_action_pressed("Right"))
		

func directional_movement() -> void:
	if falling:
		if not walled_state == walled_states.LEFT:
			if Input.is_action_pressed("Left") and not moving_left:
				moving_left = true
				timer_move_left_delay.start(BUTTON_HOLD_DELAY)
		
		if not walled_state == walled_states.RIGHT:
			if Input.is_action_pressed("Right") and not moving_right:
				moving_right = true
				timer_move_right_delay.start(BUTTON_HOLD_DELAY)
			
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
			
func _on_move_delay_left_timeout():
	if moving_left and Input.is_action_pressed("Left") and walled_state != walled_states.LEFT and downward_movement_allowed:
		object.position.x -= MOVE_SPEED_HORIZ
		timer_move_left_delay.start(BUTTON_HOLD_DELAY)
	else:
		moving_left = false
		
func _on_move_delay_right_timeout():
	if moving_right and Input.is_action_pressed("Right") and walled_state != walled_states.RIGHT and downward_movement_allowed:
		object.position.x += MOVE_SPEED_HORIZ
		timer_move_right_delay.start(BUTTON_HOLD_DELAY)
	else:
		moving_right = false
	
	
func _on_area_main_entered(area) -> void:
	match area.name:
		"Ground":
			if object.is_bottom_piece:
				falling = false
			else:
				bottom_component_movement.falling = false
				
		"Wall_L":
			if object.is_bottom_piece:
				walled_state = walled_states.LEFT
			else:
				bottom_component_movement.walled_state = walled_states.LEFT
		"Wall_R":
			if object.is_bottom_piece:
				walled_state = walled_states.RIGHT
			else:
				bottom_component_movement.walled_state = walled_states.RIGHT
		_:
			pass

func _on_area_main_exited(area) -> void:
	match area.name:
		"Wall_L":
			if object.is_bottom_piece:
				walled_state = walled_states.NEITHER
			else:
				bottom_component_movement.walled_state = walled_states.NEITHER
		"Wall_R":
			if object.is_bottom_piece:
				walled_state = walled_states.NEITHER
			else:
				bottom_component_movement.walled_state = walled_states.NEITHER
		_:
			pass
			
func _on_area_main_cushion_entered(area) -> void:
	if area.name == "Ground":
			if object.is_bottom_piece:
				downward_movement_allowed = false
			else:
				bottom_component_movement.downward_movement_allowed = false
