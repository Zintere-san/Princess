extends State
class_name ChaseStateEnemy

@export var enemy : BaseEnemy

var cast : Array = [Vector2(0,-1), Vector2(1,-1), Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(-1,-1)]
var interest : Array = [0,0,0,0,0,0,0,0]
var danger : Array = [0,0,0,0,0,0,0,0]

signal target_reached


func Enter():

	enemy.anim_player.play("idle")
func Update(delta):

	enemy.nav_agent.target_position = enemy.player.position
	var current_location = enemy.position
	var next_location = enemy.nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	for i in cast.size():
		interest[i] = float("%.2f" % cast[i].normalized().dot(Vector2(new_velocity.x, new_velocity.z)))
	assess_dangers()
	var desired_velocity = Vector3(cast[interest.find(interest.max())].x, 0, cast[interest.find(interest.max())].y).normalized() * enemy.speed
	var current_velocity = enemy.get_velocity()
	var steering_force = (desired_velocity - current_velocity) * get_parent().steering_value
	enemy.nav_agent.set_velocity(enemy.velocity + (steering_force * delta))

func Physics_Update(_delta):
	pass

func Exit():
	pass
	
func assess_dangers():
	danger = [0,0,0,0,0,0,0,0]
	for raycast in enemy.casts.get_children():
		var array_spot = int(str(raycast.name))
		if raycast.is_colliding():
			var origin = raycast.global_transform.origin
			var collision_point = raycast.get_collision_point()
			var distance = float("%.2f" % origin.distance_to(collision_point))
			danger [array_spot] += 5 - distance
			danger [(array_spot + 1) % danger.size()] += (5 - distance) / 2
			danger [(array_spot - 1) % danger.size()] += (5 - distance) / 2

	for i in interest.size():
		interest [i] -= danger [i]

func _on_navigation_agent_3d_target_reached():
	emit_signal("target_reached")

