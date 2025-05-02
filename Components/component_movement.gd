class_name Component_Movement extends Timer

@onready var object: Node = get_parent()

const FALL_SPEED: float = .4
var falling: bool = true

var has_wall_on_right: bool = false
var has_wall_on_left: bool = false

var has_piece_on_right: bool = false
var has_piece_on_left: bool = false
var has_piece_on_down: bool = false

func _ready() -> void:
	object.grounded.connect(_on_grounded)
	
	object.unblocked_right.connect(_on_unblocked_right)
	object.blocked_right.connect(_on_blocked_right)
	
	object.unblocked_left.connect(_on_unblocked_left)
	object.blocked_left.connect(_on_blocked_left)
	
	object.unblocked_bottom.connect(_on_unblocked_bottom)
	object.blocked_bottom.connect(_on_blocked_bottom)
	
	timeout.connect(_on_timeout)
	start(.5)
	
	
func _input(_event: InputEvent) -> void:
	if not has_wall_on_left:
		if not has_piece_on_left:
			object.position.x -= float(Input.is_action_pressed("Left"))
	if not has_wall_on_right:
		if not has_piece_on_right:
			object.position.x += float(Input.is_action_pressed("Right"))
	
func _on_timeout():
	if falling:
		object.position.y -= FALL_SPEED
	else:
		stop()
	
func _on_grounded() -> void:
	falling = false
	
func _on_unblocked_right(is_walled: bool) -> void:
	if is_walled:
		has_wall_on_right = false
	else:
		has_piece_on_right = false
func _on_blocked_right(is_walled: bool) -> void:
	if is_walled:
		has_wall_on_right = true
	else:
		has_piece_on_right = true
	
func _on_unblocked_left(is_walled: bool) -> void:
	if is_walled:
		has_wall_on_left = false
	else:
		has_piece_on_left = false
func _on_blocked_left(is_walled: bool) -> void:
	if is_walled:
		has_wall_on_left = true
	else:
		has_piece_on_left = true
	
func _on_unblocked_bottom() -> void:
	has_piece_on_down = false
func _on_blocked_bottom() -> void:
	has_piece_on_down = true
	
	
	
