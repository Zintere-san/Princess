extends State
class_name IdleStateEnemy
@export var enemy : BaseEnemy

func Enter():
	enemy.anim_player.play("idle")
	enemy.vision_area.monitoring = true
	enemy.sound_area.monitoring = true
	enemy.vision_time.start()
	for i in enemy.casts.get_children():
		i.enabled = false
		
	print("Enter idle")
func Update(_delta):
	pass
	
func Physics_Update(_delta):
	pass
	
func Exit():
	enemy.vision_area.monitoring = false
	enemy.sound_area.monitoring = false
	enemy.vision_time.stop()
	for i in enemy.casts.get_children():
		i.enabled = true
	print("Exit idle")
