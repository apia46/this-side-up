class_name Level
extends Node3D

enum STATES {
	NONE = -1,
	INVALID,
	SOLID,
	BOX,
	BOX_HELD
}

@onready var stateGrid: GridMap = %stateGrid
var game: Game
@export var levelData: LevelData # reference 
@export var conditions: Dictionary[String, int] = {}
var currentConditions: Dictionary[String, Variant] = {}

@export var canLift: bool = true
@export var canFreecam: bool = true
@export var data: Dictionary[Vector3i, ObjectState]

var objects: Dictionary = {solid={},goals={},gates={},triggers={}}
var allObjects: Array = []
var currentFile: String

var topBound = null
var bottomBound = null
var leftBound = null
var rightBound = null

var inputOverride: bool = false

var turnCount: int = 0

func _ready():
	get_node("/root/game/ui/levelName").text = game.LEVEL_NAMES[currentFile]
	processConditions()

func init(_currentFile, _game):
	currentFile = _currentFile
	game = _game
	game.level = self
	if currentFile not in game.levelData: game.levelData[currentFile] = LevelData.new()
	levelData = game.levelData[currentFile]
	
	for cell in %tileGrid.get_used_cells():
		match %tileGrid.get_cell_item(cell):
			0: # wall
				%stateGrid.set_cell_item(cell, STATES.SOLID)
			1: # halfwall
				%stateGrid.set_cell_item(cell, STATES.SOLID)
		if topBound == null or topBound > cell.z: topBound = cell.z
		if bottomBound == null or bottomBound < cell.z: bottomBound = cell.z
		if leftBound == null or leftBound > cell.x: leftBound = cell.x
		if rightBound == null or rightBound < cell.x: rightBound = cell.x
	
	var id = 0
	for cell in %objectGrid.get_used_cells():
		var objectType
		var layer = "solid"
		var actualCell = cell
		while %stateGrid.get_cell_item(actualCell - Vector3i(0,1,0)) == STATES.NONE:
			actualCell -= Vector3i(0,1,0)
		match %objectGrid.get_cell_item(cell):
			0:
				if levelData.spawnLocation != Vector3i(0,-1,0):
					actualCell = levelData.spawnLocation
					while %stateGrid.get_cell_item(actualCell - Vector3i(0,1,0)) == STATES.NONE:
						actualCell -= Vector3i(0,1,0)
				objectType = Player
			1:
				objectType = Box
				%stateGrid.set_cell_item(actualCell, STATES.BOX)
			2:
				objectType = BoxGoal
				layer = "goals"
			3:
				objectType = Gate
				%stateGrid.set_cell_item(actualCell, STATES.SOLID)
				layer = "gates"
			4:
				objectType = SelectGoal
				layer = "goals"
			5:
				objectType = SelectBox
				%stateGrid.set_cell_item(actualCell, STATES.BOX)
			6:
				objectType = Trigger
				layer = "triggers"
		if objectType:
			var object
			if cell in data: object = objectType.New(actualCell, self, data[cell].duplicate())
			else: object = objectType.New(actualCell, self)
			if object is BoxGoal and object.state.condition != "none":
				if object.state.condition in conditions: conditions[object.state.condition] += 1
				else:
					currentConditions[object.state.condition] = 0
					conditions[object.state.condition] = 1
			objects[layer][actualCell] = object
			object.id = str(id)
			add_child(object)
			allObjects.append(object)
			id += 1
	
	%objectGrid.visible = false
	return self

func loadLevel(level):
	queue_free()
	addAllToStack()
	get_node("/root/game").add_child(load("res://assets/levels/"+level+".tscn").instantiate().init(level, game))

func restart(): loadLevel(currentFile)

func processConditions():
	for condition in conditions:
		currentConditions[condition] = 0
	for object in objects.goals:
		var goal = objects.goals[object]
		var box = goal.getBox()
		if goal is SelectGoal:
			if box is SelectBox:
				changeLevel(goal.state.levelSet + "/" + box.state.levelFile)
		else:
			if box and (box is not SelectBox or box.state.won): currentConditions[goal.state.condition] += 1
	for object in objects.gates:
		var gate = objects.gates[object]
		if checkCondition(gate.state.condition): gate.open()
		else: gate.close()
	if checkCondition("win"): win()

func checkCondition(condition):
	if condition in game.levelData and game.levelData[condition].won: return true
	return condition in currentConditions and currentConditions[condition] == conditions[condition]

func win():
	levelData.won = true
	changeLevel("map")

func changeLevel(to):
	inputOverride = true
	await get_tree().create_timer(0.5).timeout
	loadLevel(to)

func addRawChangeToStack(change):
	print("turncount", turnCount)
	if len(game.undoStack) == 0 or game.undoStack[-1][0] != currentFile or len(game.undoStack[-1][1]) > turnCount:
		game.undoStack.append([currentFile, []])
	if len(game.undoStack[-1][1]) < turnCount:
		game.undoStack[-1][1].append([])
	game.undoStack[-1][1][-1].append(change)

func addChangeToStack(id:String, property:int, value): addRawChangeToStack([id, property, value])

func addAllToStack():
	print("hi")
	addRawChangeToStack(["all"])
