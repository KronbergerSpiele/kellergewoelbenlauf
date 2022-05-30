extends Node2D
class_name Game

const PIECE_SIZE = 480
const LOOKAHEAD = 960
const LOOKBEHIND = 960

var generatedFor = PIECE_SIZE

var score = 0.0 setget setScore, getScore
var hasStarted = false
var shouldQuickStart = false

func _ready():
  Events.connect("death", self, "onDeath")
  Events.connect("end", self, "onEnd")
  Events.connect("treasure", self, "onTreasure")
  Events.connect("walkedDistance", self, "onWalkedDistance")
  
  if Global.isFirstStart:
    Global.isFirstStart = false
    $Pieces/Start.queue_free()
    generatedFor = PIECE_SIZE * 2
  else:
    shouldQuickStart = true
    $Pieces/FirstStart.queue_free()
    $Intro/Explain.hide()
    $AnimationPlayer.play("FadeIn")
    modulate = Color(0, 0, 0, 1)
  
  $UI/Score.modulate = Color(1, 1, 1, 0)
  $Intro/Click.modulate = Color(1, 1, 1, 1)
  $Intro/Explain.modulate = Color(1, 1, 1, 0)

  onPlayerNameChanged(JSGD.playerName)  
  JSGD.connect("playerNameChanged", self, "onPlayerNameChanged")

func onPlayerNameChanged(newName):
  $UI/Name.text = newName

func setScore(new):
  score = new
  $UI/Score.text = str(int(new))

func getScore():
   return score

func triggerStart():
  if hasStarted:
    return
  hasStarted = true
  
  $Footsteps/Emitter.emitting = true
  $Intro/AnimationPlayer.play("Start")
  if shouldQuickStart:
    Events.emit_signal("quickStart")
  Events.emit_signal("start")

func _input(event):
  if !hasStarted && (event.is_action_pressed("pushMouse") || event.is_action_pressed("pushUp") || event.is_action_pressed("pushDown")):
    triggerStart()  
  elif event.is_action_pressed("pushUp"):
    Events.emit_signal("pushUp")
  elif event.is_action_pressed("pushDown"):
    Events.emit_signal("pushDown")
  elif event.is_action_pressed("pushMouse"):
    var up = (event.position.y/get_viewport_rect().size.y) < 0.5
    Events.emit_signal("pushUp" if up else "pushDown")

func _process(_delta):
  $Footsteps.position = $Player.position
  if $Player.position.x + LOOKAHEAD > generatedFor:
    appendPiece()

onready var TEMPLATES = Util.listFilesInDirectory("res://pieces/")

func appendPiece():
  var rand:int = randi() % TEMPLATES.size()
  var template = TEMPLATES[rand]
  var piece = load(template).instance()
  piece.position.x = generatedFor
  generatedFor += PIECE_SIZE
  $Pieces.add_child(piece)
  
func onDeath():
  $Footsteps/Emitter.emitting = false
  
func onEnd():  
  JSGD.reportScore(int(score))
  get_tree().reload_current_scene()

func onTreasure():
  score += 100
  
func onWalkedDistance(distance: float):
  self.score += distance / 10
