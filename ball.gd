extends RigidBody2D

func hit(impulse, position):
	apply_impulse(impulse, position)

func set_ball(impulse):
	linear_velocity = Vector2.ZERO
	apply_central_impulse(impulse)

func receive(impulse):
	linear_velocity = Vector2.ZERO
	apply_central_impulse(impulse)
