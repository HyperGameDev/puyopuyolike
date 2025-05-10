class_name Component_topPiece extends Component

var bottom_piece: Node3D
var component_bottom_piece: Component_bottomPiece

const MOVE_SPEED_ROTATE: float = .1
var rotate_position: rotate_positions
enum rotate_positions {TOP,RIGHT,BOTTOM,LEFT}
var rotating: bool = false

var rotation_offset_top: Vector3
var rotation_offset_left: Vector3
var rotation_offset_bottom: Vector3
var rotation_offset_right: Vector3

func _ready() -> void:
	piece.ground_detected_by_main.connect(_on_ground_detected_by_main)
	piece.ground_detected_by_cushion.connect(_on_ground_detected_by_cushion)
	
	bottom_piece = piece.get_parent()

func _process(_delta: float) -> void:
	check_top_rotation()
	if found_bottom_component_ref():
		return
	
func found_bottom_component_ref() -> bool:
	component_bottom_piece = Globals.current_bottom_component
	return Globals.current_bottom_component != null
		
func check_top_rotation() -> void:
	if rotating:
		for area: Area3D in %Area_Overlap.get_overlapping_areas():
			match area.name:
				"Wall_L":
					bottom_piece.position.x += 1 
					
				"Wall_R":
					bottom_piece.position.x -= 1
					
				"Ground":
					bottom_piece.position.y += 1
					
				_:
					pass

func set_rotate_position(offset_top: Vector3, offset_left: Vector3, offset_bottom: Vector3, offset_right: Vector3) -> void:
	rotation_offset_top = offset_top
	rotation_offset_left = offset_left
	rotation_offset_bottom = offset_bottom
	rotation_offset_right = offset_right

func choose_ccw_direction() -> void:
	match rotate_position:
		rotate_positions.TOP:
			rotate_piece(rotation_offset_left,rotate_positions.LEFT)
		rotate_positions.LEFT:
			rotate_piece(rotation_offset_bottom,rotate_positions.BOTTOM)
		rotate_positions.BOTTOM:
			rotate_piece(rotation_offset_right,rotate_positions.RIGHT)
		rotate_positions.RIGHT:
			rotate_piece(rotation_offset_top,rotate_positions.TOP)

func choose_cw_direction() -> void:
	match rotate_position:
		rotate_positions.TOP:
			rotate_piece(rotation_offset_right,rotate_positions.RIGHT)
		rotate_positions.RIGHT:
			rotate_piece(rotation_offset_bottom,rotate_positions.BOTTOM)
		rotate_positions.BOTTOM:
			rotate_piece(rotation_offset_left,rotate_positions.LEFT)
		rotate_positions.LEFT:
			rotate_piece(rotation_offset_top,rotate_positions.TOP)

func rotate_piece(direction: Vector3,new_position: rotate_positions) -> void:
	var tween: Tween = %RotationTweens.create_tween()
	rotating = true
	tween.finished.connect(_on_rotation_tween_finished)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(piece, "position", direction, MOVE_SPEED_ROTATE)
	rotate_position = new_position

func _on_rotation_tween_finished() -> void: 
	rotating = false

func _on_ground_detected_by_main() -> void:
	if not component_bottom_piece.downward_dash_allowed:
		component_bottom_piece.try_placing_piece()

func _on_ground_detected_by_cushion(detected: Area3D) -> void:
	if component_bottom_piece.moving_down:
		component_bottom_piece.snap_to_ground(false,detected)
		
	component_bottom_piece.downward_dash_allowed = false
