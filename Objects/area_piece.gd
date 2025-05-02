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
	%Area_Right.area_entered.connect(_on_area_right_entered)
	%Area_Right.area_exited.connect(_on_area_right_exited)
	
	%Area_Bottom.area_entered.connect(_on_area_bottom_entered)
	%Area_Bottom.area_exited.connect(_on_area_bottom_exited)

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
		
func _on_area_right_entered(area) -> void:
	if not itself(area):
		if fallen:
			match area.get_parent().piece_type:
				Piece.piece_types.PLAYER:
					area.get_parent().blocked_left.emit(false)
					print("player blocked on left")
				Piece.piece_types.PLACED:
					check_for_match(area.get_parent())
				_:
					pass
		else:
			if area.name == "%Area_Right":
				blocked_right.emit(false)
				print("player blocked on right")

func _on_area_right_exited(area) -> void:
	if not itself(area):
		if fallen:
			match area.get_parent().piece_type:
				Piece.piece_types.PLAYER:	
					area.get_parent().unblocked_left.emit(false)
					print(name,": ",name," unblocked on left at ")
				Piece.piece_types.PLACED:
					check_for_match(area.get_parent())
				_:
					pass
		else:
			unblocked_right.emit(false)

func _on_area_bottom_entered(area) -> void:
	if not itself(area):
		if fallen:
			check_for_match(area.get_parent())
		else:
			blocked_bottom.emit()
		
func _on_area_bottom_exited(area) -> void:
	if not itself(area):
		unblocked_bottom.emit()

func itself(area_to_check_against) -> bool:
	if area_to_check_against.get_parent() == self:
		return true
	return false

#func piece_seen_by_left

#func piece_seen_by_top

func check_for_match(area) -> void:
	pass
