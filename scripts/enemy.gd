extends CharacterBody2D

@export var max_speed := 140.0
@export var accel := 900.0

@onready var player: CharacterBody2D = get_node('../Player')
@export var turn_brake := 1400.0
@export var gravity := 1500.0
@export var stop_distance := 8.0

# get a reference to the collision
@onready var detect: Area2D = $Area2D

var aggro := false
func _ready() -> void:
	# I can remove this because they are connected together
	#detect.body_entered.connect(_on_area_2d_body_entered)
	#detect.body_exited.connect(_on_area_2d_body_exited)
	#set_physics_process(false)
	pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player or body.is_in_group("player"):
		aggro = true
		print("aggro on")
	#E 0:00:01:342   enemy.gd:17 @ _ready(): Signal 'body_exited' is already connected to given callable 'CharacterBody2D(enemy.gd)::_on_area_2d_body_exited' in that object.
  #<C++ Error>   Method/function failed. Returning: ERR_INVALID_PARAMETER
  #<C++ Source>  core/object/object.cpp:1451 @ connect()
  #<Stack Trace> enemy.gd:17 @ _ready()



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player or body.is_in_group("player"):
		aggro = false
		print("aggro off")


func _physics_process(delta: float) -> void:
	if _on_area_2d_body_entered:
		
		# check if there was a collision made
		if not aggro or not is_instance_valid(player):
			velocity.x = move_toward(velocity.x, 0.0, turn_brake * delta)
			move_and_slide()
			return

		# vertical (gravity)
		if not is_on_floor():
			velocity.y += gravity * delta

		# horizontal chase
		# get the x position of the player
		var dx := player.global_position.x - global_position.x
		# get the direction 
		var dir := signf(dx)                     # -1, 0, or 1
		# 
		var target_vx := 0.0
		
		# if the player position is greater than the stop distance from the player
		if absf(dx) > stop_distance:
			target_vx = dir * max_speed          # run toward player
		# else: target_vx stays 0 to stop near the player
		
		
		# strong brake if trying to turn around
		var rate := accel
		if dir != 0.0 and signf(velocity.x) != dir and is_on_floor():
			rate = turn_brake

		velocity.x = move_toward(velocity.x, target_vx, rate * delta)

		move_and_slide()

		if dir != 0.0:
			$AnimatedSprite2D.flip_h = dir < 0.0
