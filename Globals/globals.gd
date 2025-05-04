extends Node

const COMPONENTS: Dictionary[String,PackedScene] = {
	"bottomPiece": preload("res://Components/component_bottomPiece.tscn"),
	"topPiece": preload("res://Components/component_top_piece.tscn"),
	"pieceArea": preload("res://Components/component_piece_area.tscn")
}

const PIECE_SCENE: PackedScene = preload("res://Objects/piece.tscn")
const PIECE_AREA_SCENE: PackedScene = preload("res://Components/component_piece_area.tscn")

const DEBUG_MATERIAL_TOP_PIECE: StandardMaterial3D = preload("res://Materials/debug_material_piece_top.tres")

const GROUND_POS: float = 1.
const WALL_L_POS: float = 1.
const WALL_R_POS: float = 6.

var current_bottom_component: Node3D
var current_top_component: Node3D
