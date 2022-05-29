extends StaticBody2D

onready var game: Game = $"/root/Game/"
onready var powerUp = game.js().playerPowerup

export var baseSpeed: float = 65.0
export var speedFactor: float = 2.0

var accumulatedSpeed: float = 0.0

func _ready():
  Events.connect("powerUp", self, "onPowerUp")
  Events.connect("quickStart", self, "onQuickStart")
  Events.connect("death", self, "onDeath")
  
func _process(delta):
  if !game.hasStarted:
    return
  var progress = (baseSpeed + accumulatedSpeed) * delta * powerUp
  position.x += progress
  game.score += progress / 10
  accumulatedSpeed += delta * speedFactor

func onDeath():
  print('on death')
  self.queue_free()

func onPowerUp(): 
  pass
  
func onQuickStart(): 
  print('qs')
  $AnimationPlayer.play("QuickStart")
