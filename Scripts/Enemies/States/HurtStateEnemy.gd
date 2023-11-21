extends State
class_name HurtStateEnemy
@export var enemy : BaseEnemy
signal lala(nome)


func Enter():
	emit_signal("lala", "haha")
func Update(_delta):
	pass
func Physics_Update(_delta):
	pass
func Exit():
	pass
