extends CharacterBody3D


const SPEED: float = 10.0
const FALL_SPEED: float = -1.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += FALL_SPEED * delta
		
		if Input.is_action_pressed("Down"):
			print("hello")
			velocity.y += (FALL_SPEED * 100) * delta
			
		if Input.is_action_just_released("Down"):
			velocity.y = (FALL_SPEED * 40) * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis := Input.get_axis("Left", "Right")
	var direction := transform.basis * Vector3(input_axis,0,0)
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
