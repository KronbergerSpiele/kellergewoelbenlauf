extends Camera2D
onready var player = get_node("/root/Game/Player")
func _process (_delta):
  position.x = player.position.x + 200
