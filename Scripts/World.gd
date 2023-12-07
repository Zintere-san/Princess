extends Node3D

@onready var player = $Player
@onready var aggro = []
@onready var camera_fwd := Vector3.ZERO


func _ready():
	for i in $Enemies.get_children(true):
		if i is CharacterBody3D:
			i.player = player
			#i.nav_agent.target_position = player.position



#var item = array[randi() % array.size()]
#pick random from array


