extends CanvasLayer

static var ref: CanvasLayer

@onready var button_spawn: Button = %Button_Spawn
@onready var button_level: Button = %Button_Level

var bottom_component: Node3D
var top_component: Node3D

func _init() -> void:
	ref = self

func _ready() -> void:
	button_spawn.pressed.connect(_on_button_spawn_pressed)
	button_level.pressed.connect(_on_button_level_pressed)
	
func _on_button_spawn_pressed() -> void:
	Globals.current_bottom_component.queue_free()
	Globals.current_top_component.queue_free()
	
	Main_Scene.ref.spawn_piece(Piece.piece_types.BOTTOM)
	
func _on_button_level_pressed() -> void:
	#Globals.level += 1
	#var new_level: int = Globals.level
	#SignalBus.change_level.emit(new_level)
	
	match Globals.level:
		1:
			Camera.ref.animation.play("level_1-2")
			Globals.level = 2
			SignalBus.change_level.emit(2)
			
		2:
			Camera.ref.animation.play("level_next")
			Globals.level = 3
			SignalBus.change_level.emit(3)
			
		3:
			Globals.level = 1
			SignalBus.restart.emit()
			
		_:
			pass
			
	
