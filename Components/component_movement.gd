class_name Component_Movement extends Timer

@onready var object: Node = get_parent()

const FALL_SPEED: float = .4
var falling: bool = true

var can_move_horizonally: bool = true

func _ready() -> void:
	object.grounded.connect(_on_grounded)
	#object.walls.connect(_on_walled)
	timeout.connect(_on_timeout)
	start(.5)
	
	
func _input(_event: InputEvent) -> void:
	if can_move_horizonally:
		object.position.x -= Input.get_axis("Right","Left")
	
func _on_timeout():
	if falling:
		object.position.y -= FALL_SPEED
	else:
		stop()
	
func _on_grounded() -> void:
	falling = false
	
func _on_walled() -> void:
	can_move_horizonally = false
	
	
	
	
