class_name Piece extends Node3D

@warning_ignore("unused_signal")
signal ground_detected_by_main

@warning_ignore("unused_signal")
signal ground_detected_by_cushion

@export var piece_mesh: MeshInstance3D

var falling: bool = true
@export var fallen: bool = false

@export var piece_type: piece_types
enum piece_types {BOTTOM,TOP,GARBAGE,PLACED,PRESET,AI}

@export var piece_color: piece_colors
enum piece_colors {GARBAGE,RED,YELLOW,GREEN,BLUE,PURPLE}

var walled_state: walled_states
enum walled_states {NEITHER,LEFT,RIGHT}

static func assign_color(piece_to_change: Node3D, material: StandardMaterial3D) -> void:
	piece_to_change.piece_mesh.set_material_overlay(material)
