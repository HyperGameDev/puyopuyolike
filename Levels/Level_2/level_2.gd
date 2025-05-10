extends Node3D

@export_range(1,16) var my_level: int

@onready var animation_level: AnimationPlayer = $Animation_Level
@onready var ground_pieces: Node3D = $Ground_Pieces


func _ready() -> void:
	SignalBus.change_level.connect(_on_change_level)
	SignalBus.any_transition_ended.connect(_on_any_transition_ended)
	
	animation_level.play("RESET")
	
func _on_change_level(level: int) -> void:
	if level == my_level: #Drop last level's blocks
		animation_level.play("transition")
		ground_pieces.visible = false
		
func _my_transition_ended() -> void:
	ground_pieces.visible = true
	SignalBus.any_transition_ended.emit(my_level)
	
func _on_any_transition_ended(level: int) -> void:
	print("transition ended on ",my_level, " from ",level)
	if level == my_level + 1:
		ground_pieces.visible = true
	if level  == my_level - 1:
		ground_pieces.visible = false
