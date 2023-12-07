extends State
class_name HurtStateEnemy
@export var enemy : BaseEnemy

signal hurt_no_more

func Enter():
	await get_tree().process_frame
	enemy.nav_agent.target_position = enemy.global_position + enemy.calc_player_direction() * 5
	
func Update(_delta):
	var current_location = enemy.global_position
	var next_location = enemy.nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	enemy.nav_agent.set_velocity(new_velocity * 2)
	enemy.nav_agent.get_final_position()

func Physics_Update(_delta):
	pass
func Exit():
	pass


func _on_navigation_agent_3d_target_reached():
	print(enemy.name)
	hurt_no_more.emit()
