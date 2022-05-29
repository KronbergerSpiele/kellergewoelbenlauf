extends Node2D
class_name Game

const PIECE_SIZE = 480
const LOOKAHEAD = 960
const LOOKBEHIND = 960

onready var player: Player = $player
onready var scoreLabel: Label = $UI/score
onready var introClick: Node2D = $Intro/Click
onready var introExplain: Node2D = $Intro/Explain
onready var pieces = $pieces
onready var startPiece = $pieces/Start
onready var animations = $AnimationPlayer
onready var footsteps: Node2D = $footsteps
onready var global: GlobalManager = $"/root/Global"

#start is 20 blocks long
var generatedFor = PIECE_SIZE

var score = 0 setget setScore, getScore
var hasStarted = false
var shouldQuickStart = false

func js() -> JSGDAbstractClient:
  return $"/root/JSGDClientManager".client 

func _ready():
  loadPieces()
  if global.isFirstStart:
    global.isFirstStart = false
    $pieces/Start.queue_free()
    generatedFor = PIECE_SIZE * 2
  else:
    shouldQuickStart = true
    $pieces/FirstStart.queue_free()
    introExplain.hide()
  
  scoreLabel.modulate = Color(1, 1, 1, 0)
  introClick.modulate = Color(1, 1, 1, 1)
  introExplain.modulate = Color(1, 1, 1, 0)
  if js().playerPowerup > 1.1:
    $footsteps/emitter.color = Color(1, 0, 0, 1)
    $footsteps/emitter.scale_amount = 12

func setScore(new):
  score = new
  scoreLabel.text = str(int(new))

func getScore():
   return score

func triggerStart():
  if hasStarted:
    return
  hasStarted = true
  
  $Intro/AnimationPlayer.play("Start")
  if shouldQuickStart:
    $puller/AnimationPlayer.play("QuickStart")

func _input(event):
  if !hasStarted && (event.is_action_pressed("pushMouse") || event.is_action_pressed("pushUp") || event.is_action_pressed("pushDown")):
    triggerStart()  
  elif event.is_action_pressed("pushUp"):
    player.pushUp()
  elif event.is_action_pressed("pushDown"):
    player.pushDown()
  elif event.is_action_pressed("pushMouse"):
    var up = (event.position.y/get_viewport_rect().size.y) < 0.5
    player.pushUp() if up else player.pushDown()


func _process(_delta):
  footsteps.position = player.position
  if player.position.x + LOOKAHEAD > generatedFor:
    appendPiece()

var TEMPLATES = []

func listFilesInDirectory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(path+file)

    dir.list_dir_end()

    return files
    
func loadPieces():
  TEMPLATES = listFilesInDirectory("res://pieces/")

func appendPiece():
  var rand:int = randi() % TEMPLATES.size()
  var template = TEMPLATES[rand]
  var piece = load(template).instance()
  piece.position.x = generatedFor
  generatedFor += PIECE_SIZE
  pieces.add_child(piece)
  
var triggeredEnd = false  
func end():
  if triggeredEnd:
    return
  triggeredEnd = true
  
  if $puller:
    $puller.queue_free() 
  player.mass=65535
  player.contact_monitor=false
  player.linear_velocity=Vector2(0,0)
  $footsteps/emitter.emitting = false
  
  var playerAnimation = $player/AnimationPlayer
  playerAnimation.play('Death')
  yield(playerAnimation, "animation_finished")
  
  js().reportScore(int(score))
  get_tree().reload_current_scene()

