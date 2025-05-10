class_name Piece_Single extends CharacterBody3D

@onready var collision: CollisionShape3D = $CollisionShape3D


const FALL_SPEED: float = -1.5

var separated: bool = false

@export var piece_type: piece_types
enum piece_types {PAIR,GARBAGE,PLACED,PRESET}

func _physics_process(delta: float) -> void:
	if separated and not is_on_floor():
		velocity.y += FALL_SPEED * delta

func separate_from_pair() -> void:
	reparent(Game_Scene.ref.grid)
	collision.disabled = false
	separated = true
	print("it's definitely running")
