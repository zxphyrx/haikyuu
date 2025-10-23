extends CharacterBody2D

@export var jump_height: float
@export var speed: float
@export var hit_time: float

var collisions := {
	"hit": false,
	"set": false,
	"receive": false
}

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if active and arrow.visible == false:
		show_arrow()
	elif !active and arrow.visible == true:
		hide_arrow()
		
	move_and_slide()
	
func jump():
	velocity.y = jump_height
	
func move(direction):
	if not is_on_floor():
		return
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

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
