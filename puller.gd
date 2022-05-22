extends StaticBody2D

onready var game: Game = $"/root/Game/"
onready var powerUp = game.js().playerPowerup

export var speed: float = 65.0
export var speedFactor: float = 2.0

func _process(delta):
  if !game.hasStarted:
    return
  var progress = speed * delta * powerUp
  position.x += progress
  game.score += progress / 10
  speed += delta * speedFactor
