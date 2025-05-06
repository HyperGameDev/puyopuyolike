extends Node

const LEVEL: int = 1
var level: int = 1


const PIECE_SCENE: PackedScene = preload("res://Objects/Pieces/piece.tscn")
const PIECE_AREA_SCENE: PackedScene = preload("res://Components/component_piece_area.tscn")

const COMPONENTS: Dictionary[String,PackedScene] = {
	"bottomPiece": preload("res://Components/component_bottomPiece.tscn"),
	"topPiece": preload("res://Components/component_top_piece.tscn"),
	"pieceArea": preload("res://Components/component_piece_area.tscn")
}

const COLORS: Dictionary[Piece.piece_colors,StandardMaterial3D] = {
	Piece.piece_colors.BEDROCK: preload("res://Objects/Textures/color_bedrock.tres"),
	Piece.piece_colors.FOSSIL: preload("res://Objects/Textures/color_fossil.tres"),
	Piece.piece_colors.SAND: preload("res://Objects/Textures/color_sand.tres"),
	Piece.piece_colors.DIRT: preload("res://Objects/Textures/color_dirt.tres"),
	Piece.piece_colors.MOSSY: preload("res://Objects/Textures/color_mossy.tres"),
	Piece.piece_colors.STONE: preload("res://Objects/Textures/color_stone.tres"),
	Piece.piece_colors.OBSIDIAN: preload("res://Objects/Textures/color_obsidian.tres")
	
}

const DIRT_SHADOW: StandardMaterial3D = preload("res://Levels/Textures/dirt_shadow.tres") 

const DEBUG_MATERIAL_TOP_PIECE: StandardMaterial3D = preload("res://Materials/debug_material_piece_top.tres")

const GROUND_POS: float = 1.
const WALL_L_POS: float = 1.
const WALL_R_POS: float = 6.

var current_bottom_component: Component_bottomPiece
var current_top_component: Component_topPiece

func _ready() -> void:
	SignalBus.restart.connect(_on_restart)
	
func _on_restart() -> void:
	Globals.level = LEVEL
	get_tree().change_scene_to_file("res://main_scene.tscn")
	#get_tree().reload_current_scene()
