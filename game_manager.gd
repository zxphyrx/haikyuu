extends Node2D

@onready var ball: RigidBody2D = $Ball

const HITTER_SPEED = 600.0
const SETTER_SPEED = 300.0

var current_player_index := 0
var current_player: CharacterBody2D
var other_player: CharacterBody2D
var players := {}
var enemies := {}
var touches := 0
var side := ""

func switch(): 
	current_player.hide_arrow()
	current_player.move(0, 0)
	other_player = players[players.keys()[current_player_index]]
	current_player_index = ~current_player_index
	current_player = players[players.keys()[current_player_index]]
	current_player.show_arrow()

func touch():
	touches += 1
	switch()

func arc(direction, time, lift := 1.0):
	var velocity_x = direction.x / time
	var velocity_y = (direction.y - 0.5 * ball.get_gravity().y * time * time) / time
	
	velocity_y *= lift
	
	var impulse = (Vector2(velocity_x, velocity_y) * ball.mass)
	
	return impulse

func _ready() -> void:
	players = {
		"hitter": $Players/PlayerHitter,
		"setter": $Players/PlayerSetter
	}
	enemies = {
		"hitter": $Enemies/EnemyHitter,
		"setter": $Enemies/EnemySetter
	}
	current_player = players["hitter"]
	other_player = players["setter"]
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("player_switch") and touches == 0:
		switch()
		
	if Input.is_action_just_pressed("ui_accept") and current_player.is_on_floor():
		current_player.jump()
		
	if Input.is_action_just_pressed("hit") and !current_player.is_on_floor() and current_player.collisions["hit"] == true:
		var target: CharacterBody2D
		var tilt := Input.get_axis("left", "right")
		
		target = enemies["hitter"]
		
		var direction = (target.get_node("SetArea").global_position - ball.position)
		var time = 0.5
		
		ball.hit(arc(direction, time, 0.9))
		touch()
	
	if Input.is_action_just_pressed("receive") and current_player.is_on_floor() and current_player.collisions["receive"] == true:
		var target: CharacterBody2D
		var tilt := Input.get_axis("left", "right")
		
		if tilt == -1:
			if other_player.position.x < current_player.position.x:
				target = other_player
			else:
				target = current_player
		else:
			if other_player.position.x > current_player.position.x:
				target = other_player
			else:
				if enemies["hitter"].position.x > enemies["setter"].position.x:
					target = enemies["hitter"]
				else:
					target = enemies["setter"]
		
		var direction = (target.get_node("SetArea").global_position - ball.position)
		var time = 2.5
		ball.receive(arc(direction, time, 1.2))
		touch()
		
	if Input.is_action_just_pressed("set") and current_player.collisions["set"] == true:
		var direction = (players["hitter"].position - ball.position).normalized()
		var forward_force = direction
		var tilt := Input.get_axis("left", "right")
		
		if tilt == 0:
			forward_force = direction * 0
		elif tilt == -1:
			forward_force = direction * 150
		elif tilt == 1:
			forward_force = direction * -150
		
		var upward_force = Vector2(0, -250)
		var impulse = forward_force + upward_force
		ball.set_ball(impulse)
		touch()
		
	var direction := Input.get_axis("left", "right")
	players["hitter"].move(direction, HITTER_SPEED)
	players["setter"].move(direction, SETTER_SPEED)
