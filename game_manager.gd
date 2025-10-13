extends Node2D

@onready var ball: RigidBody2D = $Ball

var current_player_index := 0
var current_player: CharacterBody2D
var players := {}
var tilt = {
	"left": false,
	"right": false
}

func _ready() -> void:
	players = {
		"hitter": $Players/PlayerHitter,
		"setter": $Players/PlayerSetter,
	}
	current_player = players["hitter"]
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("player_switch"):
		current_player.move(0)
		current_player.active = false
		current_player_index = ~current_player_index
		current_player = players[players.keys()[current_player_index]]
		current_player.active = true
		
	if Input.is_action_just_pressed("ui_accept") and current_player.is_on_floor():
		current_player.jump()
		
	if Input.is_action_just_pressed("hit") and !current_player.is_on_floor() and current_player.collision == true:
		var impulse: Vector2
		var tilt = Input.get_axis("left", "right")
		if tilt == 0:
			impulse = Vector2(500, 200)
		elif tilt == -1:
			impulse = Vector2(500, 100)
		elif tilt == 1:
			impulse = Vector2(400, 300)
		
		ball.hit(impulse, current_player.get_node("Area2D").position - ball.position)
	
	if Input.is_action_just_pressed("recieve") and current_player.is_on_floor() and current_player.collision == true:
		var direction = (players["setter"].position - ball.position).normalized()
		
		var forward_force = direction
		var tilt := Input.get_axis("left", "right")
		
		if tilt == 0:
			forward_force = direction * 0
		elif tilt == -1:
			forward_force = direction * -150
		elif tilt == 1:
			forward_force = direction * 150
		
		var upward_force = Vector2(0, -250)
		var impulse = forward_force + upward_force
		
		ball.receive(impulse)
		
	if Input.is_action_just_pressed("set") and current_player.collision == true:
		ball.set_ball()
		
	var direction := Input.get_axis("left", "right")
	
	current_player.move(direction)
