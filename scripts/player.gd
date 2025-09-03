extends CharacterBody2D
@onready var health_bar := get_node("../healna/TextureProgressBar")

@onready var punch_hitbox: Area2D = $PunchHitBox
@onready var punch_shape: CollisionShape2D = $PunchHitBox/CollisionShape2D

@onready var player: AnimatedSprite2D = $AnimatedSprite2D

signal health_changed(hp:int)

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
		player.play("idle")
	else:
		player.stop()
	
	if Input.is_action_just_pressed("punch"):
		_start_punch()
	
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
		player.flip_h = input_dir < 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initialize the health bar
	print(health_bar)
	health_bar.set_hp(hp)  # start full
	player.frame_changed.connect(_on_frame_changed_)
	# initialize the punch animation
	punch_shape.disabled = true

func _start_punch():
	player.play("punch")
	await player.animation_finished
	punch_shape.disabled = true


func change_hp(delta_hp: int) -> void:
	hp = clampi(hp + delta_hp, 0, max_hp)
	health_changed.emit(hp)  # notify listeners



func _on_frame_changed_():
	if player.animation == "punch":
		var impact := player.frame in [0, 1, 2]
		punch_shape.disabled = not impact
	else:
		punch_shape.disabled = true



func _on_punch_hit_box_body_entered(body: Node2D) -> void:
	if not punch_shape.disabled and body.is_in_group("enemy"):
		print("punching!")
		#body.take_damage(1)
