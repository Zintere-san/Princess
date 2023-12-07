extends StateMachine

func _on_chase_target_reached():
	change_state($Hurt)
