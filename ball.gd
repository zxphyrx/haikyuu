extends RigidBody2D

func hit(impulse, position):
	apply_impulse(impulse, position)

func set_ball():
	linear_velocity = Vector2.ZERO
	apply_central_impulse(Vector2(0, -300))
