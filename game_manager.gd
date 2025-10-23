extends Node2D

@onready var ball: RigidBody2D = $Ball
@onready var net: StaticBody2D = $Net
@onready var score: Label = $Score

var current_character: CharacterBody2D
var current_player: CharacterBody2D
var current_enemy: CharacterBody2D
var players := {}
var player_index := 0
var enemies := {}
var enemy_index := 0
var characters := {}
var side := ""
var rally_finished := false
var player_touches = []
var enemy_touches = []
var points = {
	"player": 0,
	"enemy": 0
}

func get_closest(character, direction):
	var possible_characters = []
	
	for key in characters.keys():
		var possible_character = characters[key]
		var distance = character.position.x - possible_character.position.x
		
		if possible_character == character:
			pass
		
		if (distance < 0) == (direction > 0):
			possible_characters.append(possible_character)
		
	return possible_characters

func switch_player(direction):
	var possible_players = get_closest(current_player, direction)
	var new_player: CharacterBody2D
	
	for player in possible_players:
		if player not in player_touches:
			new_player = player
			break
	
	if new_player == current_player or new_player.name.begins_with("Enemy"):
		return
		
	print(current_player)
	current_player.move(0)
	current_player.active = false
	
	current_player = new_player
	
	current_player.active = true

func touch():
	if current_player.name.begins_with("Enemy"):
		enemy_touches.append(current_enemy)
	else:
		player_touches.append(current_player)

func arc(direction, time, lift := 1.0):
	var velocity_x = direction.x / time
	var velocity_y = (direction.y - 0.5 * ball.get_gravity().y * time * time) / time
	
	velocity_y *= lift
	
	var impulse = (Vector2(velocity_x, velocity_y) * ball.mass)
	
	return impulse

func update_score():
	score.text = "%s - %s" % [points["player"], points["enemy"]]

func handle_player():
	if Input.is_action_just_pressed("player_switch_left"):
		switch_player(-1)
	
	if Input.is_action_just_pressed("player_switch_right"):
		switch_player(1)
	
	if Input.is_action_just_pressed("ui_accept") and current_player.is_on_floor():
		current_player.jump()
		
	if Input.is_action_just_pressed("hit") and !current_player.is_on_floor() and current_character.collisions["hit"] == true:
		var target: CharacterBody2D
		var tilt := Input.get_axis("left", "right")
		
		target = enemies["enemy_hitter"]
		
		var direction = (target.get_node("SetArea").global_position - ball.position)
		var time = current_character.hit_time
		
		ball.hit(arc(direction, time))
		touch()
		switch_player(1)
	
	if Input.is_action_just_pressed("receive") and current_character.is_on_floor() and current_character.collisions["receive"] == true:
		var target: CharacterBody2D
		var tilt := Input.get_axis("left", "right")
		
		if tilt == 0:
			tilt = 1
		
		target = get_closest(current_player, tilt)[0]
		
		var direction = (target.get_node("SetArea").global_position - ball.position)
		var time = 2.5
		ball.receive(arc(direction, time, 1.2))
		touch()
		switch_player(tilt)
		
	if Input.is_action_just_pressed("set") and current_character.collisions["set"] == true:
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
		switch_player(1)
		
	var direction := Input.get_axis("left", "right")
	
	current_character.move(direction)

func handle_ball():
	if ball.on_floor == true and not rally_finished:
		rally_finished = true
		if side == "left":
			points["enemy"] += 1
		if side == "right":
			points["player"] += 1
			
		update_score()
		await get_tree().create_timer(3).timeout
		new_rally()

func new_rally():
	rally_finished = false

func _ready() -> void:
	players = {
		"libero": $Players/PlayerLibero,
		"setter": $Players/PlayerSetter,
		"hitter": $Players/PlayerHitter
	}
	enemies = {
		"enemy_hitter": $Enemies/EnemyHitter,
		"enemy_setter": $Enemies/EnemySetter
	}
	current_player = players["libero"]
	current_player.active = true
	current_character = current_player
	characters = players.duplicate()
	characters.merge(enemies)
	update_score()
	
func _physics_process(delta: float) -> void:
	if ball.position.x < net.position.x:
		side = "left"
		current_character = current_player
	else:
		side = "right"
		current_character = current_enemy
	handle_player()
	handle_ball()
