class_name body_Component_bottomPiece extends Body_Component

@onready var timer_idle_move: Timer = $Timer_Idle_Move
@onready var timer_move_left_delay: Timer = $Timer_Move_Left_Delay
@onready var timer_move_right_delay: Timer = $Timer_Move_Right_Delay
@onready var timer_fallen_delay: Timer = $Timer_Fallen_Delay

var component_top_piece: body_Component_topPiece

var top_piece: Node3D

var fall_speed: float = .5

var idle_movement: bool = true

const MOVE_SPEED_HORIZ: float = 1.
const BUTTON_HOLD_DELAY: float = .06
var moving_left: bool = false
var moving_right: bool = false
var moving_down: bool = false

var downward_dash_allowed: bool = true

func _ready() -> void:
	piece.ground_detected_by_main.connect(_on_ground_detected_by_main)
	piece.ground_detected_by_cushion.connect(_on_ground_detected_by_cushion)
	
	#timer_idle_move.timeout.connect(_on_idle_move_timeout)
	#timer_idle_move.start(fall_speed)
	
	top_piece = Main_Scene.ref.spawn_piece(Piece.piece_types.TOP,piece)
	component_top_piece = Globals.current_top_component

func _physics_process(delta: float) -> void:
		idle_moving(delta)
		directional_movement(delta)
		if not move_delay_timer_is_running():
			rotational_movement(delta)
		

func idle_moving(delta) -> void:
	piece.velocity.y *= -fall_speed * delta
	
	move_and_slide()

func move_delay_timer_is_running() -> bool:
	return is_greater_approx(timer_move_left_delay.time_left,0.) or is_greater_approx(timer_move_right_delay.time_left,0.)
	
static func is_greater_approx(a: float, b: float, tolerance: float = 0.1) -> bool:
	return a > b and (a - b) > tolerance
	
func _on_idle_move_timeout() -> void:
	if idle_movement:
		piece.velocity.y -= fall_speed
	else:
		timer_idle_move.stop()
		
func rotational_movement(delta) -> void:
	send_offset_data_to_top_piece()
	
	if Input.is_action_just_pressed("Button 1"):
		component_top_piece.choose_ccw_direction()
		
	if Input.is_action_just_pressed("Button 2"):
		component_top_piece.choose_cw_direction()
		
func send_offset_data_to_top_piece() -> void:
	component_top_piece.set_rotate_position(get_rotational_offset(Vector3(0,1.,0)), get_rotational_offset(Vector3(-1,0,0)), get_rotational_offset(Vector3(0,-1,0)), get_rotational_offset(Vector3(1.,0,0)))

func get_rotational_offset(offset: Vector3) -> Vector3:
	return Vector3(
		position.x if offset.x == 0 else offset.x,
		position.y if offset.y == 0 else offset.y,
		position.z if offset.z == 0 else offset.z
	)

func directional_movement(delta) -> void:
	if Input.is_action_pressed("Left"):
			piece.velocity.x *= -MOVE_SPEED_HORIZ * delta
	if Input.is_action_pressed("Right"):
			piece.velocity.x *= MOVE_SPEED_HORIZ * delta
			
	
	move_and_slide()

	
func piece_placed() -> void:
	print("PIECE PLACED")
	idle_movement = false
	
	Globals.current_bottom_component.queue_free()
	Globals.current_top_component.queue_free()
	Main_Scene.ref.spawn_piece(Piece.piece_types.BOTTOM)
		
func _on_ground_detected_by_main() -> void:
	if not downward_dash_allowed:
		piece_placed()
	
func _on_ground_detected_by_cushion(detected: Area3D) -> void:
	if Input.is_action_pressed("Down"):
		snap_to_ground(true,detected)
		
	downward_dash_allowed = false
	
func snap_to_ground(is_bottom: bool, ground: Area3D) -> void:
	var tween: Tween = create_tween()
	var ground_pos: float
	
	if is_bottom:
		ground_pos = ground.position.y + 1
	else:
		ground_pos = ground.position.y + 2
		
	tween.tween_property(piece, "position:y", ground_pos, .01)
		
