extends State
class_name HurtStateEnemy
@export var enemy : BaseEnemy

signal hurt_no_more

var knockback_distance = 0

func Enter():
	await get_tree().process_frame
	knockback_distance = enemy.global_position + enemy.calc_player_direction() * 2
	
func Update(_delta):
	enemy.nav_agent.target_position = knockback_distance
	var current_location = enemy.global_position
	var next_location = enemy.nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	enemy.nav_agent.set_velocity(new_velocity * 2)


func Physics_Update(_delta):
	pass
func Exit():
	pass

func _on_navigation_agent_3d_target_reached():
	hurt_no_more.emit()
