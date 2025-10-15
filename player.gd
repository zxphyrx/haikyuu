extends CharacterBody2D

@onready var arrow: Sprite2D = $Arrow

const JUMP_VELOCITY = -800.0
const SPEED = 600.0

var collisions := {
	"hit": false,
	"set": false,
	"receive": false
}

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

func show_arrow():
	arrow.show()
	
func hide_arrow():
	arrow.hide()

func _on_hit_area_body_entered(body: Node2D) -> void:
	collisions["hit"] = true

func _on_hit_area_body_exited(body: Node2D) -> void:
	collisions["hit"] = false

func _on_set_area_body_entered(body: Node2D) -> void:
	collisions["set"] = true

func _on_set_area_body_exited(body: Node2D) -> void:
	collisions["set"] = false

func _on_receive_area_body_entered(body: Node2D) -> void:
	collisions["receive"] =true

func _on_receive_area_body_exited(body: Node2D) -> void:
	collisions["receive"] = false
