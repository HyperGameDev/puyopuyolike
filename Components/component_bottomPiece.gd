class_name Component_bottomPiece extends Component

@onready var timer_idle_move: Timer = $Timer_Idle_Move
@onready var timer_move_left_delay: Timer = $Timer_Move_Left_Delay
@onready var timer_move_right_delay: Timer = $Timer_Move_Right_Delay
@onready var timer_fallen_delay: Timer = $Timer_Fallen_Delay

var component_top_piece: Component_topPiece

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
	
	timer_move_left_delay.timeout.connect(_on_move_delay_left_timeout)
	timer_move_right_delay.timeout.connect(_on_move_delay_right_timeout)
	
	timer_idle_move.timeout.connect(_on_idle_move_timeout)
	timer_idle_move.start(fall_speed)
	
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
	if idle_movement:
		piece.position.y -= fall_speed
	else:
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
	if piece.falling:
		if not near_wall(walled_states.LEFT):
			if Input.is_action_pressed("Left") and not moving_left:
				moving_left = true
				timer_move_left_delay.start(BUTTON_HOLD_DELAY)
		
		if not near_wall(walled_states.RIGHT):
			if Input.is_action_pressed("Right") and not moving_right:
				moving_right = true
				timer_move_right_delay.start(BUTTON_HOLD_DELAY)
			
		if(Input.is_action_pressed("Down") and not moving_down) and downward_dash_allowed:
			moving_down = true
			while(true):
				if(not Input.is_action_pressed("Down") or not falling or not downward_dash_allowed): break
				
				piece.position.y -= fall_speed
				
				await get_tree().create_timer(BUTTON_HOLD_DELAY/25).timeout
			moving_down = false
			
func near_wall(wall_state: walled_states) -> bool:
	return wall_state == piece.walled_state or wall_state == top_piece.walled_state
			
func _on_move_delay_left_timeout() -> void:
	if moving_left and Input.is_action_pressed("Left") and not near_wall(walled_states.LEFT) and downward_dash_allowed:
		piece.position.x -= MOVE_SPEED_HORIZ
		timer_move_left_delay.start(BUTTON_HOLD_DELAY)
	else:
		moving_left = false
		
func _on_move_delay_right_timeout() -> void:
	if moving_right and Input.is_action_pressed("Right") and not near_wall(walled_states.RIGHT) and downward_dash_allowed:
		piece.position.x += MOVE_SPEED_HORIZ
		timer_move_right_delay.start(BUTTON_HOLD_DELAY)
	else:
		moving_right = false
	
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
		
