class_name Game_Scene extends Node3D

static var ref: Node3D

@onready var grid: Node3D = %Grid

func _init() -> void:
	ref = self

func _ready() -> void:
	spawn_pair()

func spawn_pair() -> void:
	if Globals.current_pair_controller == null:
		var pair_to_spawn: CharacterBody3D = Globals.PAIR_SCENE.instantiate()
		grid.add_child(pair_to_spawn)
		pair_to_spawn.position = Globals.PAIR_SPAWN_POS
	else:
		clear_old_pair()
		
func clear_old_pair() -> void:
	Globals.current_top_piece.separate_from_pair()
	Globals.current_bottom_piece.separate_from_pair()
	
	Globals.current_pair_controller.queue_free()
	Globals.current_pair_controller = null
	
	spawn_pair()
	
	
