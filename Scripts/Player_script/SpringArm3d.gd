extends SpringArm3D
var mouse_sens = 0.002

var boss = false

func _ready():
	set_as_top_level(true)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not boss:
		rotation.y -= event.relative.x * mouse_sens

func _process(_delta):
	get_parent().camera_forward = -global_transform.basis.z 
	if boss == true:
		look_at(get_tree().current_scene.get_node("Rock").position)
	rotation.x = deg_to_rad(-45)
