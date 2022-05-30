extends StaticBody2D

export var baseSpeed: float = 65.0
export var speedFactor: float = 2.0

var accumulatedSpeed: float = 0.0

func _ready():
  Events.connect("start", self, "onStart")
  Events.connect("powerUp", self, "onPowerUp")
  Events.connect("quickStart", self, "onQuickStart")
  Events.connect("death", self, "onDeath")
  
var hasStarted = false  
func _process(delta):
  if !hasStarted:
    return
  
  var progress = (baseSpeed + accumulatedSpeed) * delta * JSGD.playerPowerUp
  position.x += progress
  Events.emit_signal("walkedDistance", progress)
  accumulatedSpeed += delta * speedFactor

func onStart():
  hasStarted = true

func onDeath():
  self.queue_free()

func onPowerUp(): 
  $AnimationPlayer.play("PowerUp")
  
func onQuickStart(): 
  $AnimationPlayer.play("QuickStart")
