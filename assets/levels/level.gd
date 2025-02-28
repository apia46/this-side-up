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

var objects: Dictionary[String, Array] = {solid=[],goals=[],gates=[],triggers=[]}
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
		var objectSlug = %objectGrid.get_cell_item(cell)
		if objectSlug < len(game.OBJECT_CLASSES): objectType = game.OBJECT_CLASSES[%objectGrid.get_cell_item(cell)]
		else: assert(false)
		match objectType:
			Player:
				if levelData.spawnLocation != Vector3i(0,-1,0):
					actualCell = levelData.spawnLocation
					while %stateGrid.get_cell_item(actualCell - Vector3i(0,1,0)) == STATES.NONE:
						actualCell -= Vector3i(0,1,0)
			Box, SelectBox:
				%stateGrid.set_cell_item(actualCell, STATES.BOX)
			BoxGoal, SelectGoal:
				layer = "goals"
			Gate:
				%stateGrid.set_cell_item(actualCell, STATES.SOLID)
				layer = "gates"
			Trigger:
				layer = "triggers"
		var object
		if cell in data: object = objectType.New(actualCell, self, data[cell].duplicate())
		else: object = objectType.New(actualCell, self)
		if object is BoxGoal and object.state.condition != "none":
			if object.state.condition in conditions: conditions[object.state.condition] += 1
			else:
				currentConditions[object.state.condition] = 0
				conditions[object.state.condition] = 1
		objects[layer].append(object)
		object.id = str(id)
		add_child(object)
		allObjects.append(object)
		id += 1
	
	%objectGrid.visible = false
	return self

func loadLevel(level, undoing:=false):
	queue_free()
	if !undoing: addAllToStack()
	var _level = load("res://assets/levels/"+level+".tscn").instantiate().init(level, game)
	game.add_child(_level)
	return _level

func restart(): loadLevel(currentFile)

func processConditions():
	for condition in conditions:
		currentConditions[condition] = 0
	for goal in objects.goals:
		var box = goal.getBox()
		if goal is SelectGoal:
			if box is SelectBox:
				changeLevel(goal.state.levelSet + "/" + box.state.levelFile)
		else:
			if box and (box is not SelectBox or box.state.won): currentConditions[goal.state.condition] += 1
	for gate in objects.gates:
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
	if len(game.undoStack[-1][1]) < turnCount or len(game.undoStack[-1][1]) == 0:
		game.undoStack[-1][1].append([])
	game.undoStack[-1][1][-1].append(change)

func addChangeToStack(id:String, property:int, value): addRawChangeToStack([id, property, value])

func addAllToStack():
	var all = []
	for object in allObjects:
		all.append([object.id, object.state.serialise()])
	addRawChangeToStack(["all", turnCount, all])

func getObject(layer, location):
	for object in objects[layer]: if object.state.position == location: return object
	return false
