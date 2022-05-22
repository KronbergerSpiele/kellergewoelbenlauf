extends RigidBody2D
class_name Player

export var push: int = 1000

onready var game = $"/root/Game"

func pushUp():
  apply_central_impulse(Vector2(0,-push))
  
func pushDown():
  apply_central_impulse(Vector2(0,push))

func onBodyEntered(body):
  var map := body as Map
  if not map:
    return
  if map.kills:
    game.end()
