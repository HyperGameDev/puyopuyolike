extends StaticBody3D

@onready var piece_mesh: Piece_Character = $Node_Piece
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var collision_paired: CollisionShape3D = $"../Collision_pairedTop"

const MOVE_SPEED_ROTATE: float = 0.1
const ROTATION_OFFSET_TOP: Vector3 = Vector3(0, 0, 0)
const ROTATION_OFFSET_LEFT: Vector3 = Vector3(-1, -1, 0)
const ROTATION_OFFSET_BOTTOM: Vector3 = Vector3(0, -2, 0)
const ROTATION_OFFSET_RIGHT: Vector3 = Vector3(1, -1, 0)

var rotate_position: rotate_positions
enum rotate_positions {TOP, RIGHT, BOTTOM, LEFT}
var rotating: bool = false

func choose_ccw_direction() -> void:
	print("choosing ccw direction")
	match rotate_position:
		rotate_positions.TOP:
			rotate_piece(ROTATION_OFFSET_LEFT, rotate_positions.LEFT)
		rotate_positions.LEFT:
			rotate_piece(ROTATION_OFFSET_BOTTOM, rotate_positions.BOTTOM)
		rotate_positions.BOTTOM:
			rotate_piece(ROTATION_OFFSET_RIGHT, rotate_positions.RIGHT)
		rotate_positions.RIGHT:
			rotate_piece(ROTATION_OFFSET_TOP, rotate_positions.TOP)

func choose_cw_direction() -> void:
	match rotate_position:
		rotate_positions.TOP:
			rotate_piece(ROTATION_OFFSET_RIGHT, rotate_positions.RIGHT)
		rotate_positions.RIGHT:
			rotate_piece(ROTATION_OFFSET_BOTTOM, rotate_positions.BOTTOM)
		rotate_positions.BOTTOM:
			rotate_piece(ROTATION_OFFSET_LEFT, rotate_positions.LEFT)
		rotate_positions.LEFT:
			rotate_piece(ROTATION_OFFSET_TOP, rotate_positions.TOP)

func rotate_piece(new_position: Vector3, new_enum_position: rotate_positions) -> void:
	collision.position = new_position
	collision_paired.global_position = collision.get_global_position()
	var tween: Tween = create_tween()
	rotating = true
	tween.finished.connect(_on_rotation_tween_finished)
	#tween.set_ease(Tween.EASE_OUT)
	#tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(piece_mesh, "position", new_position, MOVE_SPEED_ROTATE)
	
	rotate_position = new_enum_position

func _on_rotation_tween_finished() -> void: 
	rotating = false
