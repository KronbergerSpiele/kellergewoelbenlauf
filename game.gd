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

#start is 20 blocks long
var generatedFor = PIECE_SIZE * 2 

var score = 0 setget setScore, getScore
var hasStarted = false

func _ready():
  loadPieces()
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
  animations.play("Start")

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
  
func end():
  js().reportScore(int(score))
  get_tree().reload_current_scene()

func js() -> JSGDAbstractClient:
  return $"/root/JSGDClientManager".client 
