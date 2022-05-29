extends StaticBody2D

onready var game: Game = $"/root/Game/"
onready var powerUp = game.js().playerPowerup

export var baseSpeed: float = 65.0
export var speedFactor: float = 2.0

var accumulatedSpeed: float = 0.0

func _process(delta):
  if !game.hasStarted:
    return
  var progress = (baseSpeed + accumulatedSpeed) * delta * powerUp
  position.x += progress
  game.score += progress / 10
  accumulatedSpeed += delta * speedFactor
