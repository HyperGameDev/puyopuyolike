extends Node3D

@onready var grid: Node3D = %Grid

var piece: Area3D = preload("res://Objects/area_piece.tscn").instantiate()

var component_movement: Timer = preload("res://Components/component_movement.tscn").instantiate()


var spawn_pos: Vector3 = Vector3(3,13,0)


func _ready() -> void:
	SignalBus.spawn_garbage.connect(_on_spawn_garbage)
	spawn_piece(Piece.piece_types.PLAYER)
	
func spawn_piece(type_to_spawn) -> void:
	grid.add_child(piece)	
	piece.piece_type = type_to_spawn
	
	match type_to_spawn:
		Piece.piece_types.PLAYER:
			piece.position = spawn_pos
			piece.add_child(component_movement)
			
	
	
func _on_spawn_garbage() -> void:
	spawn_piece(Piece.piece_types.GARBAGE)
