extends CharacterBody3D

@export var speed : float = 7
@export var jump_height : float
@export var jump_time_peak : float
@export var jump_time_descent : float
@export var atk_area_offset : float = 1

@onready var jump_velo : float = 2.0 * jump_height / jump_time_peak
@onready var jump_grav : float = -2.0 * jump_height / jump_time_peak ** 2
@onready var fall_grav : float = -2.0 * jump_height / jump_time_descent ** 2

@onready var springarm := $SpringArm3d
@onready var animation := $AnimationPlayer 
@onready var sprite := $Sprite3d

@onready var camera_forward

enum {IDLE, WALK, JUMP, FALL, ATAK, HURT}

var animIndex : Array[Vector2] = [Vector2.LEFT, Vector2(-1,1), Vector2.DOWN, Vector2(1,1), Vector2.RIGHT, Vector2(1,-1), Vector2.UP, Vector2(-1,-1)]

var movement := Vector3.ZERO
var last_move := Vector3.ZERO
var knockback := Vector3.ZERO

var health := 100
var damage
var can_jump = true
var jump_pressed = false
var atak_pressed = false
var cur_state : int
var old_state : int
var cur_attack = 0

func _ready() -> void:
	_change_state(IDLE)
	last_move = Vector3.FORWARD

func _process(delta) -> void:
	springarm.position = position
	movement.x = Input.get_axis("L", "R")
	movement.z = Input.get_axis("U", "D")
	movement = movement.rotated(Vector3.UP, springarm.rotation.y)
	velocity.x = movement.x * speed
	velocity.z = movement.z * speed
	sprite_rotation()
	apply_gravity(delta)
	
	if Input.is_action_just_pressed("J"):
		jump_pressed = true
		await get_tree().create_timer(0.1).timeout
		jump_pressed = false

	match cur_state:
		IDLE:
			if Input.is_action_just_pressed("debug"):
				_change_state(ATAK)
			elif velocity.y < 0:
				_change_state(FALL)
			elif jump_pressed:
				_jump()
			elif movement != Vector3.ZERO:
				_change_state(WALK)
		
		WALK:
			if Input.is_action_just_pressed("debug"):
				_change_state(ATAK)
			elif velocity.y < 0:
				_change_state(FALL)
			elif jump_pressed and (is_on_floor() or can_jump):
				_jump()
			elif movement == Vector3.ZERO:
				_change_state(IDLE)
			else:
				last_move = movement
		
		JUMP:
			if is_on_floor():
				_change_state(IDLE)
			elif velocity.y < 0:
				_change_state(FALL)
		FALL:
			if is_on_floor():
				_change_state(IDLE)
			elif Input.is_action_just_pressed("debug"):
				_change_state(ATAK)
			elif jump_pressed and can_jump:
				_jump()
		ATAK:
			_knockback(delta)
#			if knockback == Vector3.ZERO:
#				$AttackHitbox.monitoring = false
#				_change_state(IDLE)
		HURT:
			_knockback(delta)
	move_and_slide()

func sprite_rotation() -> void:
	get_tree().current_scene.camera_fwd = -springarm.get_child(0).global_transform.basis.z
	camera_forward = get_tree().current_scene.camera_fwd
	var fwd_dot = last_move.dot(camera_forward)
	var lnr_dot = last_move.rotated(Vector3.UP, deg_to_rad(270)).dot(camera_forward)
	var dot_product := Vector2.ZERO
	dot_product.x = -sign(snapped(lnr_dot, 0.45))
	dot_product.y = -sign(snapped(fwd_dot, 0.45))
	if animIndex.find(dot_product) >= 0:
		sprite.frame_coords.y = animIndex.find(dot_product)

func _knockback(delta : float) -> void:
	knockback = knockback.move_toward(Vector3.ZERO, 50 * delta)
	velocity.x = move_toward(knockback.x, 0, delta)
	velocity.z = move_toward(knockback.z, 0, delta)

func apply_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y += _get_gravity() * delta

func _get_gravity() -> float:
	return jump_grav if velocity.y > 0 else fall_grav

func _jump() -> void:
	velocity.y = jump_velo
	_change_state(JUMP)

func _change_animation(anim: String) -> void:
	animation.play(anim)

func _change_state(new_state : int) -> void:
	old_state = cur_state
	cur_state = new_state
	match new_state:
		IDLE: _change_animation("Idle")
		WALK: _change_animation("Walk")
		JUMP: pass
		FALL:
			if old_state != JUMP:
				can_jump = true
				await get_tree().create_timer(0.1).timeout
				can_jump = false
		ATAK:
			$AttackHitbox.monitoring = true
			if old_state == FALL:
				velocity.y = -50
				$AttackHitbox.position = atk_area_offset * Vector3(0, -2, 0)
			else:
				
				knockback = last_move.normalized() * 15
				$AttackHitbox.position = atk_area_offset * last_move
			
		HURT:
			pass

func _on_attack_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
