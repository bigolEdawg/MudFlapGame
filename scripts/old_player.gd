extends CharacterBody2D
@onready var health_bar := get_node("../healna/TextureProgressBar")

@onready var punch_hitbox: Area2D = $Node2D
@onready var punch_shape: CollisionShape2D = $Node2D/PunchHitBox


signal health_changed(hp:int)

#@export var VELOCITY = Vector2.ZERO
#var ACCELERATION = 300
#var FRICTION = 600
#var MAX_SPEED = 400
#const GRAVITY_Y = 300

var max_hp := 100
var hp := max_hp



const RUN_ACCEL = 100
const TURN_ACCEL = 800
const FRICTION = 600.0
var VELOCITY = Vector2.ZERO
const AIR_DRAG = 10.0
const MAX_SPEED = 400.0
const JUMP_HEIGHT = 200
const JUMP_CUT = 0.5
const GRAVITY = 300
const SKIN := 1.0  # pixels


func _physics_process(delta: float) -> void:
	if velocity.x == 0 and velocity.y == 0:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.stop()
	
	if Input.is_action_just_pressed("punch"):
		$AnimatedSprite2D.play("punch")
		
	# vertical movement
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y -= JUMP_HEIGHT
	
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT
		
	# horizontal movement
	
	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if input_dir:
		var same_dir = signf(velocity.x) == signf(input_dir * MAX_SPEED) or abs(velocity.x) <= 0.001
		if is_on_floor() and not same_dir:
			velocity.x = move_toward(velocity.x, input_dir * MAX_SPEED, TURN_ACCEL * delta)
		#velocity.x += input_dir * ACCELERATION * delta
		else:
			velocity.x = move_toward(velocity.x, input_dir * MAX_SPEED, RUN_ACCEL * delta)
	else:
		# if we are on the floor then we need to clamp to the friction
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, AIR_DRAG * delta)
	move_and_slide()
	
	if input_dir:
		$AnimatedSprite2D.flip_h = input_dir < 0.0
#func _physics_process(delta: float) -> void:
	#var rc := $RayCast2D
	#var grounded = $RayCast2D.is_colliding()
	#
	#var input_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	##if not grounded:
		##VELOCITY.y += GRAVITY * delta
	##else:
		##VELOCITY.y = 0
	#
	## Horizontal Movement
	#if input_dir:
		#VELOCITY.x += input_dir * ACCELERATION * delta
		#VELOCITY.x = clamp(VELOCITY.x, -MAX_SPEED, MAX_SPEED)
	#else:
		#if grounded:
			#VELOCITY.x = move_toward(VELOCITY.x, 0.0, FRICTION * delta)
		#else:
			##VELOCITY.x = move_toward(VELOCITY.x, 0.0, AIR_DRAG * delta)
			#VELOCITY.x = lerp(VELOCITY.x, 0.0, AIR_DRAG * delta)
	#
	#
	## Vertical Movement
	#if grounded and Input.is_action_pressed("jump"):
		#VELOCITY.y -= JUMP_HEIGHT
		#print("start")
		#print(VELOCITY.y)
	#if Input.is_action_just_released("jump") and VELOCITY.y < 0.0:
		#VELOCITY.y *= JUMP_CUT
	#
	## Constant downward force
	#var motion = VELOCITY * delta
	## Clamp downward motion to floor distance
	#if motion.y > 0.0 and grounded:
		#var dist_to_floor = rc.get_collision_point().y - rc.global_position.y
		## If we'd move past the floor this frame, clamp and zero Y velocity
		#if dist_to_floor <= motion.y + SKIN:
			#motion.y = max(dist_to_floor - SKIN, 0.0)
			#VELOCITY.y = 0.0
		#
	#print(VELOCITY.y)
	#print("end")
#
	## integrate the calculations into the position
	#position += motion * delta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initialize the health bar
	print(health_bar)
	health_bar.set_hp(hp)  # start full
	
	# initialize the punch animation
	punch_shape.disabled = true

func _start_punch():
	$AnimatedSprite2D.play("punch")
	
	await $AnimatedSprite2D.animation_finished
	punch_shape.disabled = true
	


func change_hp(delta_hp: int) -> void:
	hp = clampi(hp + delta_hp, 0, max_hp)
	health_changed.emit(hp)  # notify listeners
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#
	#
	## ACCELERATION -> a = dv / dt
	## position = position + velocity*t + 1/2 * a * t^2
#
	## check if the ray cast 2D is collidining with the ground
	#if $RayCast2D.is_colliding():
		#VELOCITY.y = 0
	#else:
		## add the gravity
		#VELOCITY.y += GRAVITY_Y * delta
	#
	## Check the direction we are moving in	
	#if Input.is_action_pressed("move_right"):
		#if $RayCast2D.is_colliding():
			#$AnimatedSprite2D.flip_h = false
		#VELOCITY.x += ACCELERATION * delta
		#print("pressed")
	#elif Input.is_action_pressed("move_left"):
		#if $RayCast2D.is_colliding():
			#$AnimatedSprite2D.flip_h = true
		#VELOCITY.x -= ACCELERATION * delta
	#else: # if we arent pressing left or right anymore then we need to slow down
		#VELOCITY.x = move_toward(VELOCITY.x,0.0, FRICTION * delta)
	#
	## Clamp the velocity to a max value. velocity is a vector therfore 
	## it has direction so we also check for the negative speed
	#VELOCITY.x = clamp(VELOCITY.x, -MAX_SPEED, MAX_SPEED)
	#
	#'''
	#check if we are jumping
	#we can only jump if our ray cast is on the ground
	#'''	
	#if Input.is_action_pressed("jump") and $RayCast2D.is_colliding():
		#VELOCITY.y -= 200
		#
	#position += VELOCITY * delta
