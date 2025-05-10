class_name Main_Scene extends Node3D

static var ref: Node3D

@onready var grid: Node3D  = %Grid
@onready var ground_area: Area3D = %Ground

var spawn_pos_playable_piece: Vector3 = Vector3(3,13,0)

func _init() -> void:
	ref = self

func _ready() -> void:
	SignalBus.spawn_garbage.connect(_on_spawn_garbage)
	
	spawn_piece(Piece.piece_types.BOTTOM)
	
func spawn_piece(type_to_spawn: Piece.piece_types, parent: Node3D = grid) -> Node3D:
	var piece_to_spawn: Node3D
	
	match type_to_spawn:
		Piece.piece_types.BOTTOM:
			piece_to_spawn = add_piece(parent,type_to_spawn)
			setup_bottom_piece(piece_to_spawn)
		Piece.piece_types.TOP:
			piece_to_spawn = add_piece(parent,type_to_spawn)
			setup_top_piece(piece_to_spawn,parent)
		Piece.piece_types.GARBAGE:
			setup_garbage_piece()
	
	return piece_to_spawn

func add_piece(parent: Node3D,piece_type: Piece.piece_types) -> Node3D:
	var piece_to_add: Node3D = Globals.PIECE_SCENE.instantiate()
	parent.add_child(piece_to_add)
	piece_to_add.piece_type = piece_type
	add_collision_areas(piece_to_add,piece_to_add)
	
	return piece_to_add

func setup_bottom_piece(piece_to_add: Node3D) -> void:
	piece_to_add.position = spawn_pos_playable_piece
	piece_to_add.random_color(piece_to_add)
	
	var component_to_add: Node3D
	component_to_add = add_component(piece_to_add,Globals.COMPONENTS["bottomPiece"].instantiate())
	
	Globals.current_bottom_component = component_to_add
	

func setup_top_piece(piece_to_add: Node3D, _parent: Node3D) -> void:
	piece_to_add.position.y += 1.
	piece_to_add.random_color(piece_to_add)
	#piece_to_add.assign_color(piece_to_add,Globals.DEBUG_MATERIAL_TOP_PIECE)
	
	var component_to_add: Node3D
	component_to_add = add_component(piece_to_add,Globals.COMPONENTS["topPiece"].instantiate())
	
	Globals.current_top_component = component_to_add

func add_component(object: Node3D,component_to_add: Node3D) -> Node3D:
	object.add_child(component_to_add)
	return component_to_add
	
func add_collision_areas(piece: Node3D, parent: Node3D) -> void:
	var collision_to_add: Node3D = Globals.PIECE_AREA_SCENE.instantiate()
	piece.add_child(collision_to_add)
	collision_to_add.piece_added_to = parent

func setup_garbage_piece() -> void:
	pass
	
func _on_spawn_garbage() -> void:
	spawn_piece(Piece.piece_types.GARBAGE)
