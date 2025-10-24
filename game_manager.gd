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

func get_closest(character, direction, possible_characters):
	var final_character: CharacterBody2D
	
	for key in possible_characters.keys():
		var possible_character = possible_characters[key]
		var distance = character.position.x - possible_character.position.x
		
		if possible_character == character:
			pass
		
		if (distance < 0) == (direction > 0):
			if not final_character:
				final_character = possible_character
			elif (abs(character.position.x - possible_character.position.x) < abs(character.position.x - final_character.position.x)):
				final_character = possible_character
			elif (abs(character.position.x - possible_character.position.x) == abs(character.position.x - final_character.position.x)):
				if possible_character.z_index > final_character.z_index:
					final_character = possible_character
				
	return final_character

func get_farthest(character, direction, possible_characters):
	var final_character: CharacterBody2D
	
	for key in possible_characters.keys():
		var possible_character = possible_characters[key]
		var distance = character.position.x - possible_character.position.x
		
		if possible_character == character:
			pass
		
		if (distance < 0) == (direction > 0):
			if not final_character:
				final_character = possible_character
			elif (abs(character.position.x - possible_character.position.x) > abs(character.position.x - final_character.position.x)):
				final_character = possible_character
			elif (abs(character.position.x - possible_character.position.x) == abs(character.position.x - final_character.position.x)):
				if possible_character.z_index > final_character.z_index:
					final_character = possible_character
				
	return final_character

func switch_player(direction):
	var target_player = get_closest(current_player, direction, players)
	
	if !target_player:
		return
	if target_player.name.begins_with("Enemy"):
		return
		
	print(target_player)
		
	current_player.move(0)
	current_player.active = false
	
	current_player = target_player
	
	current_player.active = true

func touch():
	var touches := []
	if current_character.name.begins_with("Enemy"):
		touches = enemy_touches
	else:
		touches = player_touches
	
	if current_character in touches:
		return false
	else:
		touches.append(current_character)
		return true

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
		
	if Input.is_action_just_pressed("hit") and !current_player.is_on_floor() and current_player.collisions["hit"] == true:
		var touch_result = touch()
		
		if touch_result:
			var target: CharacterBody2D
			var tilt := Input.get_axis("left", "right")
			
			if tilt == 1:
				target = get_closest(current_player, 1, enemies)
			else:
				target = get_farthest(current_player, 1, enemies)
			
			var direction = (target.get_node("SetArea").global_position - ball.position)
			var time = current_character.hit_time
			
			ball.hit(arc(direction, time))
			switch_player(1)
	
	if Input.is_action_just_pressed("receive") and current_player.is_on_floor() and current_player.collisions["receive"] == true:
		var touch_result = touch()
		
		if touch_result:
			var target: CharacterBody2D
			var tilt := Input.get_axis("left", "right")
			
			if tilt == 0:
				tilt = 1
			
			target = get_closest(current_player, tilt, players)
			
			if !target:
				print(target)
				target = get_closest(current_player, tilt, enemies)
			
			var direction = (target.get_node("SetArea").global_position - ball.position)
			
			ball.receive(arc(direction, 2.5, 1.2))
			switch_player(1)
	
	var direction := Input.get_axis("left", "right")
	
	current_player.move(direction)

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
		"enemy_libero": $Enemies/EnemyLibero,
		"enemy_setter": $Enemies/EnemySetter,
		"enemy_hitter": $Enemies/EnemyHitter
	}
	current_player = players["libero"]
	current_player.active = true
	current_enemy = enemies["enemy_libero"]
	current_character = current_player
	
	characters = players.duplicate()
	characters.merge(enemies)
	update_score()
	
func _physics_process(delta: float) -> void:
	if ball.position.x < net.position.x and side != "left":
		side = "left"
		player_touches = []
		enemy_touches = []
	elif ball.position.x > net.position.x and side != "right":
		side = "right"
		player_touches = []
		enemy_touches = []
		
	if side == "left":
		current_character = current_player
	elif side == "right":
		current_character = current_enemy
		
	handle_player()
	handle_ball()
