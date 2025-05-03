class_name Piece extends Node3D

@export var fallen: bool = false
@export var is_bottom_piece: bool = true

@export var piece_type: piece_types
enum piece_types {PLAYER,GARBAGE,PLACED,PRESET}

@export var piece_color: piece_colors
enum piece_colors {GARBAGE,RED,YELLOW,GREEN,BLUE,PURPLE}
