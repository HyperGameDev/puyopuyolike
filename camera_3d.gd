class_name Camera extends Camera3D

static var ref: Camera3D

@onready var window_size : Vector2 = get_window().size
@onready var mouse_pos : Vector2 = get_viewport().get_mouse_position()

@onready var animation: AnimationPlayer = %Animation_Camera

func _init() -> void:
	ref = self

func _process(_delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	#general_area_ray()
	#general_body_ray()

func hover_ray(mask: int, has_mask: bool, collide_bodies: bool) -> Variant: ## Raycast that receives a target via argument
	if get_viewport() == null:
		return
	
	var ray_length: int = 3000
	var from: Vector3 = project_ray_origin(mouse_pos)
	var to: Vector3 = from + project_ray_normal(mouse_pos) * ray_length
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_query.exclude = []
	ray_query.from = from
	ray_query.to = to
	
	if collide_bodies:
		ray_query.collide_with_bodies = true
	else:
		ray_query.collide_with_areas = true
	
	# Remember: masks/layers need to be set with the bit (2^) values!
	if has_mask:
		ray_query.collision_mask = mask
	
	return space.intersect_ray(ray_query)

#func general_area_ray() -> void:
	#var general_ray_result: Variant = hover_ray(0,false,false)
	##print(general_ray_result)
#
#func general_body_ray() -> void:
	#var general_ray_result: Variant = hover_ray(0,false,true)
