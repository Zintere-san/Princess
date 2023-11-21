extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3d as NavigationAgent3D
var speed = 3
var state: int
var old_state = null
var initial_pos := Vector3()
var knockback = Vector3()
var player: CharacterBody3D
var attack_delay = 3
var can_attack = true

@onready var sprite = $Sprite3D
@onready var anim_player = $AnimationPlayer
@onready var sound_area = $SoundArea
@onready var vision_area = $VisionArea

var animIndex : Array[Vector2] = [Vector2.RIGHT, Vector2(1,-1), Vector2.UP, Vector2(-1,-1), Vector2.LEFT, Vector2(-1,1), Vector2.DOWN, Vector2(1,1)] 
enum {IDLE, WANDER, CHASE, ATTACK, COMBAT, HURT}

func _ready():
	initial_pos = global_position
	await get_tree().create_timer(0.5).timeout
	change_state(IDLE)

func _physics_process(delta):
	sprite_rotation()
	match state:
		IDLE:
			pass
		
		ATTACK:
			knockback = knockback.move_toward(Vector3.ZERO, 50 * delta)
			velocity.x = move_toward(knockback.x, 0, delta)
			velocity.z = move_toward(knockback.z, 0, delta)
			move_and_slide()
		
		CHASE:
			nav_agent.target_position = player.position
			var current_location = position
			var next_location = nav_agent.get_next_path_position()
			var new_velocity = (next_location - current_location).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
			nav_agent.set_velocity(new_velocity)
			
			#Trigger if lost player
			if position.distance_to(player.position) > 25:
				next_location = null
				change_state(IDLE)
		
		HURT:
			knockback = knockback.move_toward(Vector3.ZERO, 50 * delta)
			velocity.x = move_toward(knockback.x, 0, delta)
			velocity.z = move_toward(knockback.z, 0, delta)
			move_and_slide()
			await get_tree().create_timer(0.5).timeout
			if knockback == Vector3.ZERO:
				change_state(CHASE)

func sprite_rotation():
	var fwd_dot = global_transform.basis.z.dot(get_tree().current_scene.camera_fwd)
	var lnr_dot = global_transform.basis.z.rotated(Vector3.UP, deg_to_rad(270)).dot(get_tree().current_scene.camera_fwd)
	var dot_product := Vector2.ZERO
	dot_product.x = -sign(snapped(lnr_dot, 0.45))
	dot_product.y = -sign(snapped(fwd_dot, 0.45))
	if animIndex.find(dot_product) >= 0:
		sprite.frame_coords.y = animIndex.find(dot_product)

func _on_navigation_agent_3d_target_reached():
	if can_attack:
		change_state(ATTACK)
		nav_agent.set_velocity(Vector3.ZERO)
		await get_tree().create_timer(1.5).timeout
		change_state(CHASE)
		can_attack = true
	else:
		nav_agent.set_velocity(Vector3.ZERO)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.9)
	move_and_slide()

func take_damage(damage):
	knockback = (position - player.position).normalized() * 12
	change_state(HURT)

func attack():
	knockback = (position - player.position).normalized() * -8

func change_state(new_state):
	old_state = state
	state = new_state
	match new_state:
		IDLE:
			nav_agent.set_velocity(Vector3.ZERO)
		ATTACK:
			anim_player.play("attack")
			can_attack = false
		COMBAT: pass
		CHASE:
			anim_player.play("walk")
		HURT:
			anim_player.play("hurt")

func line_of_sight():
	$LineOfSight.look_at(player.position, Vector3.UP)
	$LineOfSight.force_raycast_update()
	if $LineOfSight.get_collider() == player:
		print("lmao")

func _on_vision_timer_timeout():
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				$LineOfSight.look_at(player.position)
				$LineOfSight.force_raycast_update()
				if $LineOfSight.is_colliding():
					var collider = $LineOfSight.get_collider()
					if collider.name == "Player":
						change_state(CHASE)
						$VisionTimer.stop()

func _on_sound_area_area_entered(area):
	if state == IDLE:
		if area.name == "Noise":
			change_state(CHASE)

func _on_vision_area_body_entered(body):
	$VisionTimer.start()

func _on_vision_area_body_exited(body):
	$VisionTimer.stop()
	$VisionTimer.wait_time = 0.5
