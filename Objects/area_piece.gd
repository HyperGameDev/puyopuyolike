class_name Piece extends Node3D

signal grounded

signal unblocked_left(is_walled:bool)
signal blocked_left(is_walled:bool)

signal unblocked_right(is_walled:bool)
signal blocked_right(is_walled:bool)

signal unblocked_bottom
signal blocked_bottom

@export var fallen: bool = false

@export var piece_type: piece_types
enum piece_types {PLAYER,GARBAGE,PLACED,PRESET}

@export var piece_color: piece_colors
enum piece_colors {GARBAGE,RED,YELLOW,GREEN,BLUE,PURPLE}

enum walled_state {NEITHER,LEFT,RIGHT}

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	if is_on_floor():
		grounded.emit()
		
	check_sides()
	
func check_sides() -> void:
	#match has_piece_nearby():
		
	match detected_walled_state():
		walled_state.NEITHER:
			unblocked_left.emit(true)
			unblocked_right.emit(true)
		walled_state.LEFT:
			blocked_left.emit(true)
			unblocked_right.emit(true)
		walled_state.RIGHT:
			blocked_right.emit(true)
			unblocked_left.emit(true)
		
func is_on_floor() -> bool:
	return is_equal_approx(position.y,Globals.GROUND_POS)

func detected_walled_state() -> walled_state:
	if is_equal_approx(position.x,Globals.WALL_L_POS):
		return walled_state.LEFT
	elif is_equal_approx(position.x,Globals.WALL_R_POS):
		return walled_state.RIGHT
	else:
		return walled_state.NEITHER
		
func _on_area_entered(area) -> void:
	if piece_sees_on_right(area):
		if fallen:
			match area.piece_type:
				Piece.piece_types.PLAYER:
					area.blocked_left.emit(false)
					print("player blocked on left")
				Piece.piece_types.PLACED:
					check_for_match()
				_:
					pass
		else:
			blocked_right.emit(false)
			
	if piece_sees_on_bottom(area):
		if fallen:
			check_for_match()
		else:
			blocked_bottom.emit()
			
func _on_area_exited(area) -> void:
	if fallen:
		match area.piece_type:
			Piece.piece_types.PLAYER:	
				if not piece_sees_on_right(area):
					area.unblocked_left.emit(false)
					print(name,": ",name," unblocked on left at ")
			Piece.piece_types.PLACED:
				check_for_match()
			_:
				pass
	else:
		unblocked_right.emit(false)
	if not piece_sees_on_bottom(area):
		unblocked_bottom.emit()
		
func piece_sees_on_right(area) -> bool:
	return is_equal_approx(area.position.x,position.x + 1.)
	
func piece_sees_on_bottom(area) -> bool:
	return is_equal_approx(area.position.y,position.y - 1.)

#func piece_seen_by_left

#func piece_seen_by_top

func check_for_match() -> void:
	pass
