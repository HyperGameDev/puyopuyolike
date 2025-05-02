class_name Piece extends Node3D

signal grounded
signal blocked_left
signal blocked_right

@export var piece_type: piece_types
enum piece_types {PLAYER,GARBAGE,PRESET}

@export var piece_color: piece_colors
enum piece_colors {GARBAGE,RED,YELLOW,GREEN,BLUE,PURPLE}

func _process(_delta: float) -> void:
	if is_on_floor():
		grounded.emit()
		
	check_sides()
	
func check_sides() -> void:
	#if 
	pass
		
func is_on_floor() -> bool:
	return is_equal_approx(position.y,Globals.GROUND_POS)

func is_on_wall() -> bool:
	return is_equal_approx(position.x,Globals.WALL_L_POS) or is_equal_approx(position.x,Globals.WALL_R_POS)
	
func is_on_piece() -> bool:
	return false
