extends Node

@onready var health_bar = get_node("healna/TextureProgressBar")
@onready var player = get_node("Player")
@onready var healna_timer := get_node("HealnaTimer") as Timer

var max_hp := 100
var hp := max_hp

func _ready():
	# health signal with hp int param
	# when we call the set_hp it will make a call to the signal
	player.health_changed.connect(health_bar.set_hp)  # wire player -> UI
	
	health_bar.set_hp(player.hp)
	# when there is a timeout signal we are going to call the on helna timer timeout
	healna_timer.wait_time = 1
	#healna_timer.timeout.connect(_on_healna_timer_timeout)
	healna_timer.start()


func _on_healna_timer_timeout() -> void:
	player.change_hp(-1)
