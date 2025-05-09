class_name Component_bottomPiece extends Component

@onready var timer_idle_move: Timer = $Timer_Idle_Move
@onready var timer_move_left_delay: Timer = $Timer_Move_Left_Delay
@onready var timer_move_right_delay: Timer = $Timer_Move_Right_Delay
@onready var timer_fallen_delay: Timer = $Timer_Fallen_Delay

var component_top_piece: Component_topPiece

var top_piece: Node3D

var FALL_SPEED: float = .5

var movement_state: movement_states
enum movement_states {IDLE_AND_DIRECTIONAL,IDLE_ONLY,NO_MOVEMENT}

var fall_state: fall_states
enum fall_states {FALLING,FALL_DELAYED,FALLEN}

const FALLEN_DELAY: float = 5.

const MOVE_SPEED_HORIZ: float = 1.
const BUTTON_HOLD_DELAY: float = .06
var moving_left: bool = false
var moving_right: bool = false
var moving_down: bool = false

var downward_dash_allowed: bool = true

func _ready() -> void:
	print("\r  NEW PIECE ")
	piece.ground_detected_by_main.connect(_on_ground_detected_by_main)
	#piece.ground_undetected_by_main.connect(_on_ground_undetected_by_main)
	piece.ground_detected_by_cushion.connect(_on_ground_detected_by_cushion)
	
	timer_move_left_delay.timeout.connect(_on_move_delay_left_timeout)
	timer_move_right_delay.timeout.connect(_on_move_delay_right_timeout)
	
	timer_idle_move.timeout.connect(_on_idle_move_timeout)
	timer_idle_move.start(FALL_SPEED)
	
	timer_fallen_delay.timeout.connect(_on_fallen_delay_timeout)
	
	top_piece = Main_Scene.ref.spawn_piece(Piece.piece_types.TOP,piece)
	component_top_piece = Globals.current_top_component

func _input(event: InputEvent) -> void:
	if(event is InputEventKey and event.is_pressed()): #Ensure a key is pressed
		directional_movement()
		if not move_delay_timer_is_running():
			rotational_movement()

func move_delay_timer_is_running() -> bool:
	return is_greater_approx(timer_move_left_delay.time_left,0.) or is_greater_approx(timer_move_right_delay.time_left,0.)
	
static func is_greater_approx(a: float, b: float, tolerance: float = 0.1) -> bool:
	return a > b and (a - b) > tolerance
	
func _on_idle_move_timeout() -> void:
	if not movement_state == movement_states.NO_MOVEMENT:
		print(" IDLY MOVING ")
		piece.position.y -= FALL_SPEED
	else: # No Movement
		timer_idle_move.stop()
		
func rotational_movement() -> void:
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

func directional_movement() -> void:
	if movement_state == movement_states.IDLE_AND_DIRECTIONAL:
		if not near_wall(walled_states.LEFT):
			if Input.is_action_pressed("Left") and not moving_left:
				moving_left = true
				timer_move_left_delay.start(BUTTON_HOLD_DELAY)
		
		if not near_wall(walled_states.RIGHT):
			if Input.is_action_pressed("Right") and not moving_right:
				moving_right = true
				timer_move_right_delay.start(BUTTON_HOLD_DELAY)
			
		if(Input.is_action_pressed("Down") and not moving_down):
			moving_down = true
			while(true):
				if(not Input.is_action_pressed("Down") or not downward_dash_allowed): break
				
				piece.position.y -= FALL_SPEED
				
				await get_tree().create_timer(BUTTON_HOLD_DELAY/25).timeout
			moving_down = false
			
func near_wall(wall_state: walled_states) -> bool:
	return wall_state == piece.walled_state or wall_state == top_piece.walled_state
			
func _on_move_delay_left_timeout() -> void:
	if moving_left and Input.is_action_pressed("Left") and not near_wall(walled_states.LEFT):
		piece.position.x -= MOVE_SPEED_HORIZ
		timer_move_left_delay.start(BUTTON_HOLD_DELAY)
	else:
		moving_left = false
		
func _on_move_delay_right_timeout() -> void:
	if moving_right and Input.is_action_pressed("Right") and not near_wall(walled_states.RIGHT):
		piece.position.x += MOVE_SPEED_HORIZ
		timer_move_right_delay.start(BUTTON_HOLD_DELAY)
	else:
		moving_right = false
		
func start_fallen_delay() -> void:
	print("Fallen Delay Started")
	timer_fallen_delay.start(FALLEN_DELAY)
	fall_state = fall_states.FALL_DELAYED
		
func _on_fallen_delay_timeout() -> void:
	if not fall_state == fall_states.FALLEN:
		print("Fallen Delay Ended")
		movement_state = movement_states.IDLE_ONLY
		fall_state = fall_states.FALLEN

func piece_placed() -> void:
	if not component_top_piece.rotating:
		print("PIECE PLACED")
		fall_state = fall_states.FALLEN
		movement_state = movement_states.NO_MOVEMENT
		Globals.current_bottom_component.queue_free()
		Globals.current_top_component.queue_free()
		Main_Scene.ref.spawn_piece(Piece.piece_types.BOTTOM)
	
func _on_ground_detected_by_main() -> void:
	is_juggling = false
	
	match fall_state: 
		fall_states.FALLING:
			start_fallen_delay()
		fall_states.FALLEN:
			print("BOTTOM: piece placed (",piece.name,")")
			piece_placed()
			
	if not downward_dash_allowed and not fall_state == fall_states.FALLEN:
		print("BOTTOM: piece dash-placed (",piece.name,")")
		piece_placed()
		
#func _on_ground_undetected_by_main() -> void:
	#timer_idle_move.start(FALL_SPEED)
	
func _on_ground_detected_by_cushion() -> void:
	downward_dash_allowed = false
	
	if is_juggling:
		if fall_state == fall_states.FALL_DELAYED:
			movement_state = movement_states.IDLE_AND_DIRECTIONAL
	else:
		if position.y > 1.:
			print("STARTED JUGGLING")
			is_juggling = true
