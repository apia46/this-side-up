class_name Game
extends Node3D

const LEVEL_NAMES = {
	"map": "",
	"set1/1": "1-1",
	"set1/2": "1-2",
	"set1/3": "1-3",
	"set1/4": "1-4",
	"set1/5": "1-5",
}
const STACK_VALUE_IDS = [
	"position",
	"rotation",
	"special",
	"high"
]

var levelData = {}
@export var undoStack = []
var level: Level

var debug: bool = false

func _ready():
	add_child(preload("res://assets/levels/map.tscn").instantiate().init("map", self))

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		debug = !debug

func undo():
	print("========")
	print(undoStack)
	if len(undoStack) == 0: return
	var actions : Array = undoStack[-1][1].pop_back()
	actions.reverse()
	print(actions)
	for action in actions:
		if action[0] == "all": print("well shit")
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
