extends State

class_name ChaseStateEnemy

@export var enemy : BaseEnemy
var cast : Array = [Vector2(0,-1), Vector2(1,-1), Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(-1,-1)]
var danger : Array = [0,0,0,0,0,0,0,0]
var interest : Array = [0,0,0,0,0,0,0,0]

func Enter():
	pass
func Update(delta):
	enemy.nav_agent.target_position = enemy.player.position
	var current_location = enemy.position
	var next_location = enemy.nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	for i in cast.size():
		interest[i] = "%.2f" % cast[i].normalized().dot(Vector2(new_velocity.x, new_velocity.z))
#		print(interest.find(interest.max()))
	assess_dangers()
	var desired_velocity = Vector3(cast[interest.find(interest.max())].x, 0, cast[interest.find(interest.max())].y).normalized() * enemy.speed
	var current_velocity = enemy.get_velocity()
	var steering_force = desired_velocity - current_velocity
	enemy.nav_agent.set_velocity(enemy.velocity + (steering_force * delta))
func Physics_Update(_delta):
	pass
func Exit():
	pass
func assess_dangers():
	pass
