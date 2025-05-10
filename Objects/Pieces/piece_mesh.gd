class_name Piece_Mesh extends Node3D

@export var piece_mesh: MeshInstance3D

@export var piece_color: piece_colors
enum piece_colors {BEDROCK,DIRT_GRASS,FOSSIL,SAND,DIRT,MOSSY,STONE,OBSIDIAN}

func random_color(piece_to_change: Node3D) -> void:
	assign_color(piece_to_change,randi_range(3,7))

static func assign_color(piece_to_change: Node3D, color: piece_colors) -> void:
	#print(color)
	var color_to_assign: StandardMaterial3D = Globals.COLORS.get(color,null)
	piece_to_change.piece_mesh.set_material_override(color_to_assign)
