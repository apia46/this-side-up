class_name Game
extends Node3D

const LEVEL_INFO = {
	"map": ["", ""],
	"set1/1": ["1-1", "Boxed In"],
	"set1/2": ["1-2", "Spread Out"],
	"set1/3": ["1-3", "Micro"],
	"set1/4": ["1-4", "Shuriken"],
	"set1/5": ["1-5", "Lane Change"],
	
	"set2/1": ["2-1", "Boxed In Again"],
	"set2/2": ["2-2", "Orientation Cube"],
	"set2/3": ["2-3", "Parallel Parking"],
	"set2/A": ["2-A", "Hammerhead", "Dr. Koffee"],
	"set2/4": ["2-4!", "Magic Trick", "Something"]
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

func _ready():
	level = preload("res://assets/levels/map.tscn").instantiate().init("map", self)
	add_child(level)

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		debug = !debug

func undo():
	#print("========")
	#print(undoStack)
	if len(undoStack) == 0: return
	var actions : Array = undoStack[-1][1].pop_back()
	actions.reverse()
	#print(actions)
	for action in actions:
		match action[0]:
			"all":
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
	if len(undoStack[-1][1]) == 0: undoStack.pop_back()
	level.turnCount -= 1
	for object in level.allObjects: object.undoCleanup()
	level.fulfillStatePromises()
	level.processConditions()
