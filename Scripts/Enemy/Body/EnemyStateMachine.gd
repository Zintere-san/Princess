extends CharacterBody3D
class_name BaseEnemy

@onready var casts       = $Steering as Node3D
@onready var sprite      = $Sprite3D as Sprite3D
@onready var sound_area  = $SoundArea as Area3D
@onready var vision_time = $VisionTimer as Timer
@onready var vision_area = $VisionArea as Area3D
@onready var anim_player = $AnimationPlayer as AnimationPlayer
@onready var nav_agent   = $NavigationAgent3d as NavigationAgent3D

var player: CharacterBody3D
var forward = Vector3()
var speed = 3

func _ready():
	$StateMachine.init()

func _physics_process(_delta):
	if not is_on_floor():
		velocity.y -= 3

func _process(_delta):
	pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.9)
	move_and_slide()

func calc_player_direction():
	return player.global_position.direction_to(global_position)
