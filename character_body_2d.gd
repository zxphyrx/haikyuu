extends CharacterBody2D
@onready var ball: RigidBody2D = $"../Ball"
@onready var area_2d: Area2D = $Area2D

const SPEED = 500.0
const JUMP_VELOCITY = -800.0
var collision = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("click") and collision == true:
		ball.apply_impulse(Vector2(500, 200), area_2d.position - ball.position)
		
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		collision = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Ball":
		collision = false
