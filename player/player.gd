extends RigidBody2D
class_name Player

export var push: int = 800

func _ready():
  Events.connect("pushUp",self,"pushUp")
  Events.connect("pushDown",self,"pushDown")

func pushUp():
  apply_central_impulse(Vector2(0,-push))
  
func pushDown():
  apply_central_impulse(Vector2(0,push))

func onBodyEntered(body):
  var map := body as Map
  if not map:
    return
  if map.kills:
    death()
  if map.powersUp:
    map.queue_free()
    Events.emit_signal("powerUp")

var triggeredDeath = false
func death():
  if triggeredDeath:
    return
  triggeredDeath = true

  mass = 65535
  contact_monitor=false
  linear_velocity=Vector2(0,0)
  Events.emit_signal("death")
  
  $AnimationPlayer.play("Death")
  yield($AnimationPlayer, "animation_finished")
  Events.emit_signal("end")
  
