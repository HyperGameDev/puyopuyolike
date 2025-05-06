extends Node3D

@onready var plane: MeshInstance3D = $Plane

func hide_shadow() -> void:
	var tween: Tween = get_tree().get_current_scene().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(plane, "material_overlay:albedo_color", Color(.19,.19,.19,.714), 1.0) 
