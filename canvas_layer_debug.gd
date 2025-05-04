extends CanvasLayer

static var ref

@onready var button_spawn: Button = %Button_Spawn

var bottom_component: Node3D
var top_component: Node3D

func _init() -> void:
	ref = self

func _ready() -> void:
	button_spawn.pressed.connect(_on_button_spawn_pressed)
	
func _on_button_spawn_pressed() -> void:
	Main_Scene.ref.spawn_piece(Piece.piece_types.BOTTOM)
	
