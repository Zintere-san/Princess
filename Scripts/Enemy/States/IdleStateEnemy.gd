extends State
class_name IdleStateEnemy
@export var enemy : BaseEnemy

signal player_detected
signal player_see
signal player_hear

func Enter():
	enemy.anim_player.play("idle")
	enemy.vision_area.monitoring = true
	enemy.sound_area.monitoring = true
	enemy.vision_time.start()
	for i in enemy.casts.get_children():
		i.enabled = false

func Exit():
	enemy.vision_area.set_deferred("monitoring", false)
	enemy.sound_area.set_deferred("monitoring", false)
	enemy.vision_time.stop()
	enemy.vision_time.wait_time = 0.5
	for i in enemy.casts.get_children():
		i.enabled = true

func _on_sound_area_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_hear")

func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_see")
