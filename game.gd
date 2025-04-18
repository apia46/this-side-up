class_name Game
extends Node3D

@onready var ui : UI = get_node("ui")
@onready var minimap = get_node("minimapViewportContainer/minimapViewport/minimap")
var hoveringMinimap := false
var minimapStage := 0.0
@onready var minimapHitbox = get_node("minimapHitbox")
var closingMinimap := false
var won := 0

const LEVEL_INFO = {
	"map": ["", ""],
	"placeholder": ["", ""], # before it loads the subsitute from the cereal, just so it doesnt crash
	"testlevel": ["", ""],
	"set1/1": ["1-1", "Boxed In"],
	"set1/2": ["1-2", "Spread Out"],
	"set1/3": ["1-3", "Micro"],
	"set1/4": ["1-4", "Shuriken"],
	"set1/5": ["1-5", "Lane Change"],
	
	"set2/1": ["2-1", "Boxed In Again"],
	"set2/2": ["2-2", "Orientation Cube"],
	"set2/3": ["2-3", "Parallel Parking"],
	"set2/4": ["2-4!", "Magic Trick", "Something"],
	"set2/5": ["2-5", "Natural"],
	"set2/A": ["2-A", "Hammerhead", "Dr. Koffee"],
	
	"set2b/0": ["2B-0!", "Wow!"],
	"set2b/1": ["2B-1", "Repetition"],
	"set2b/2": ["2B-2", "Steps"],
	"set2b/3": ["2B-3", "Misalignment"],
}
const STACK_VALUE_IDS = [
	"position",
	"rotation",
	"special",
	"high"
]
var OBJECT_CLASSES = [
	Player,
	Box,
	BoxGoal,
	Gate,
	SelectGoal,
	SelectBox,
	Trigger
]

var levelData = {}
@export var undoStack = []
var level: Level
@export var flags: Flags

var debug: bool = false
var minimapHover : LevelDisplay = null

func _ready():
	level = load("res://assets/levels/map.tscn").instantiate().init("map", self)
	add_child(level)

func _unhandled_input(event):
	if event.is_action_pressed("toggle_debug"):
		debug = !debug
		ui.debug.visible = debug

func undo(dontIfWouldLoad:=false):
	#print("========")
	#print(undoStack)
	if !undoStack: return
	var actions: Array = undoStack[-1][1].pop_back()
	var doItAgain: bool = false
	actions.reverse()
	#print(actions)
	for action in actions:
		match action[0]:
			"dummy": doItAgain = true
			"all":
				if dontIfWouldLoad:
					actions.reverse()
					undoStack[-1][1].append(actions)
					return false
				level.queue_free()
				level = level.loadLevel(undoStack[-1][0], "undo")
				level.unmakeCereal(action, "undo")
			_:
				assert(action[0].is_valid_int())
				var object = level.allObjects[int(action[0])]
				if STACK_VALUE_IDS[action[1]] == "special":
					object.specialUndo(action[2])
				else:
					var propertyWas = object.state[STACK_VALUE_IDS[action[1]]]
					object.state[STACK_VALUE_IDS[action[1]]] = action[2]
					object.undoed(STACK_VALUE_IDS[action[1]], propertyWas)
	if !undoStack[-1][1]: undoStack.pop_back()
	level.turnCount -= 1
	for object in level.allObjects: object.undoCleanup()
	level.fulfillStatePromises()
	level.processConditions()
	if doItAgain: undo(dontIfWouldLoad)
	return true

func _process(delta):
	hoveringMinimap = get_viewport().get_mouse_position().x >= 0 and get_viewport().get_mouse_position().y >= 0\
		and get_viewport().get_mouse_position().x <= minimapHitbox.size.x and get_viewport().get_mouse_position().y <= minimapHitbox.size.y
	%minimapExit.visible = hoveringMinimap and !closingMinimap and flags.unlockMinimap and won != 1
	if hoveringMinimap and !closingMinimap and flags.unlockMinimap and won != 1:
		if minimapStage == 0: minimap.go(level.currentFile)
		minimapStage = minimapStage+1.5*delta
	else:
		minimapStage *= 1-(2*delta)
		minimapStage = max(0, minimapStage - 1.5*delta)
	if minimapStage == 0: closingMinimap = false
	var easing = 1 - 2**(-minimapStage)
	var minimapHitboxSize = easing*450 + 50
	%minimapExit.modulate.a = minimapStage
	minimapHitbox.size = Vector2(minimapHitboxSize*1.3,minimapHitboxSize)
	%minimapViewportContainer.get_material().set_shader_parameter("size", easing)
	%minimapViewportContainer.get_material().set_shader_parameter("t", easing*3.8)

func _minimapExit_pressed():
	closingMinimap = true

func win():
	if won != 0: return
	won = 1
	await get_tree().create_timer(0.5).timeout
	ui.winContainer.visible = true
	create_tween().tween_property(ui.winContainer, "modulate", Color(1,1,1,1), 2)
	await get_tree().create_timer(3).timeout
	won = 2


func _winButton_pressed():
	won = 2
	ui.winContainer.visible = false
