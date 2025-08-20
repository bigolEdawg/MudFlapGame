extends Area2D
 
@onready var health_bar := get_node("../healna/TextureProgressBar")


signal health_changed(hp:int)

@export var VELOCITY = Vector2.ZERO
var ACCELERATION = 300
var FRICTION = 600
var MAX_SPEED = 400
const GRAVITY_Y = 300

var max_hp := 100
var hp := max_hp


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(health_bar)
	health_bar.set_hp(hp)  # start full

func change_hp(delta_hp: int) -> void:
	hp = clampi(hp + delta_hp, 0, max_hp)
	health_changed.emit(hp)  # notify listeners
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$healna/TextureProgressBar.set_hp(1)
	#health_bar.set_hp(1)
	#if delta:
		#change_hp(-10)

	# ACCELERATION -> a = dv / dt
	# position = position + velocity*t + 1/2 * a * t^2
	
	# check if the ray cast 2D is collidining with the ground
	if $RayCast2D.is_colliding():
		VELOCITY.y = 0
	else:
		# add the gravity
		VELOCITY.y += GRAVITY_Y * delta
	
	if Input.is_action_pressed("move_right"):
		if $RayCast2D.is_colliding():
			$AnimatedSprite2D.flip_h = false
		VELOCITY.x += ACCELERATION * delta
		print("pressed")
	elif Input.is_action_pressed("move_left"):
		if $RayCast2D.is_colliding():
			$AnimatedSprite2D.flip_h = true
		VELOCITY.x -= ACCELERATION * delta
	else:
		VELOCITY.x = move_toward(VELOCITY.x,0.0, FRICTION * delta)
	VELOCITY.x = clamp(VELOCITY.x, -MAX_SPEED, MAX_SPEED)
	
	'''
	check if we are jumping
	we can only jump if our ray cast is on the ground
	'''	
	if Input.is_action_pressed("jump") and $RayCast2D.is_colliding():
		VELOCITY.y -= 300
		
	position += VELOCITY * delta

# Check if it is entering the level node
	# if we are touching the ground then the y vecocity should be 0
