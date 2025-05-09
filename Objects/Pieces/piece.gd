class_name Piece extends Node3D

@warning_ignore("unused_signal")
signal ground_detected_by_main
@warning_ignore("unused_signal")
signal ground_undetected_by_cushion

@warning_ignore("unused_signal")
signal ground_detected_by_cushion(area: Area3D)

@export var piece_mesh: MeshInstance3D

var falling: bool = true
@export var fallen: bool = false

@export var piece_type: piece_types
enum piece_types {BOTTOM,TOP,GARBAGE,PLACED,PRESET,AI}

@export var piece_color: piece_colors
enum piece_colors {BEDROCK,DIRT_GRASS,FOSSIL,SAND,DIRT,MOSSY,STONE,OBSIDIAN}

var walled_state: walled_states
enum walled_states {NEITHER,LEFT,RIGHT}

func random_color(piece_to_change: Node3D) -> void:
	assign_color(piece_to_change,randi_range(3,7))

static func assign_color(piece_to_change: Node3D, color: piece_colors) -> void:
	#print(color)
	var color_to_assign: StandardMaterial3D = Globals.COLORS.get(color,null)
	piece_to_change.piece_mesh.set_material_override(color_to_assign)
