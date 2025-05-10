extends CharacterBody3D

@onready var top_piece: StaticBody3D = $Static_topPiece
@onready var bottom_piece: StaticBody3D = $Static_bottomPiece





const SPEED: float = 10.0
const FALL_SPEED: float = -1.5

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += FALL_SPEED * delta
		
		if Input.is_action_pressed("Down"):
			print("hello")
			velocity.y += (FALL_SPEED * 100) * delta
			
		if Input.is_action_just_released("Down"):
			velocity.y = (FALL_SPEED * 40) * delta

	var input_axis := Input.get_axis("Left", "Right")
	var direction := transform.basis * Vector3(input_axis,0,0)
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if(event is InputEventKey and event.is_pressed()): #Ensure a key is pressed
		rotational_movement()
	
func rotational_movement() -> void:
	if Input.is_action_just_pressed("Button 1"):
		top_piece.choose_ccw_direction()
		
	if Input.is_action_just_pressed("Button 2"):
		top_piece.choose_cw_direction()
