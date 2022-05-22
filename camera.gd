extends Camera2D
onready var player = get_node("/root/Game/player")
func _process (delta):
  position.x = player.position.x + 200
