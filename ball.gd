extends RigidBody2D

var on_floor = false

func _ready():
	contact_monitor = true
	max_contacts_reported = 4

func hit(impulse):
	apply_impulse(impulse)

func set_ball(impulse):
	linear_velocity = Vector2.ZERO
	apply_central_impulse(impulse)

func receive(impulse):
	linear_velocity = Vector2.ZERO
	apply_central_impulse(impulse)

func _integrate_forces(state):
	var count = state.get_contact_count()
	if count > 0:
		for i in range(count):
			var collider = state.get_contact_collider_object(i)
			
			if collider.name == "Floor":
				on_floor = true
	else:
		on_floor = false
