extends Node2D

@onready var players: Node2D = $Players
@onready var ball: RigidBody2D = $Ball

var current_player_index := 1
var current_player: CharacterBody2D
var tilt = {
	"left": false,
	"right": false
}

func _ready() -> void:
	current_player = players.get_child(current_player_index)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("player_switch"):
		current_player_index = ~current_player_index
		current_player = players.get_child(current_player_index)
		
	if Input.is_action_just_pressed("ui_accept") and current_player.is_on_floor():
		current_player.jump()
		
	if Input.is_action_just_pressed("hit") and current_player.collision == true:
		var impulse: Vector2
		var direction := Input.get_axis("left", "right")
		if direction == 0:
			impulse = Vector2(500, 200)
		elif direction == -1:
			impulse = Vector2(500, 100)
		elif direction == 1:
			impulse = Vector2(400, 300)
		
		ball.hit(impulse, current_player.get_node("Area2D").position - ball.position)
	
	if Input.is_action_just_pressed("set") and current_player.collision == true:
		ball.set_ball()
		
	var direction := Input.get_axis("left", "right")
	
	current_player.move(direction)
	
	pass
