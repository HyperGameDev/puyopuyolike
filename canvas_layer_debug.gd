extends CanvasLayer

static var ref: CanvasLayer

@onready var button_spawn: Button = %Button_Spawn

var bottom_component: Node3D
var top_component: Node3D

func _init() -> void:
	ref = self

func _ready() -> void:
	button_spawn.pressed.connect(_on_button_spawn_pressed)
	
func _on_button_spawn_pressed() -> void:
	print("button pressed yeah")
	Globals.current_bottom_component.queue_free()
	Globals.current_top_component.queue_free()
	
	Main_Scene.ref.spawn_piece(Piece.piece_types.BOTTOM)
	

	
