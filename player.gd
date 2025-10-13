extends CharacterBody2D

const JUMP_VELOCITY = -800.0
const SPEED = 500.0

var collision := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
func jump():
	velocity.y = JUMP_VELOCITY
	
func move(direction):
	if not is_on_floor():
		return
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		collision = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Ball":
		collision = false
