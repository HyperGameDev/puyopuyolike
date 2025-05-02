class_name Main_Scene extends Node3D

@onready var grid: Node3D = %Grid

static var ref

var piece: PackedScene = preload("res://Objects/area_piece.tscn")

var component_movement: Node3D = preload("res://Components/component_movement.tscn").instantiate()


var spawn_pos: Vector3 = Vector3(3,13,0)

func _init() -> void:
	ref = self

func _ready() -> void:
	SignalBus.spawn_garbage.connect(_on_spawn_garbage)
	spawn_piece(Piece.piece_types.PLAYER)
	
func spawn_piece(type_to_spawn) -> void:
	var piece_to_add: Node3D = piece.instantiate()
	grid.add_child(piece_to_add)	
	piece_to_add.piece_type = type_to_spawn
	
	match type_to_spawn:
		Piece.piece_types.PLAYER:
			piece_to_add.position = spawn_pos
			piece_to_add.add_child(component_movement)
			
	
	
func _on_spawn_garbage() -> void:
	spawn_piece(Piece.piece_types.GARBAGE)
