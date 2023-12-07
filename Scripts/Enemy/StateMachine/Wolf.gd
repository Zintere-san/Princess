extends StateMachine
#Wolf enemy
var steering_value = 1

func _on_idle_player_detected():
	change_state($Ambush)

func _on_idle_player_hear():
	change_state($Ambush)

func _on_idle_player_see():
	change_state($Ambush)

func _on_ambush_target_reached():
	pass # Replace with function body.

func _on_hurt_hurt_no_more():
	change_state($Idle)
