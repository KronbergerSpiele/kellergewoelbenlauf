extends Node2D

func _ready():
  onPlayerPowerUpChanged(JSGD.playerPowerUp)
  JSGD.connect("playerPowerUpChanged", self, "onPlayerPowerUpChanged")
    
func onPlayerPowerUpChanged(value):
  if value is Array:
    value = value[0]
  $Emitter.scale_amount = 7+log(7*(max(0.01,value-1)))
