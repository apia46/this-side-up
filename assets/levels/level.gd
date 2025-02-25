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

@export var levelNumber: String
@export_file("*.tscn") var nextLevel: String
@export var canLift: bool = true
@export var canFreecam: bool = true
@export var data: Dictionary[Vector3i, ObjectState]

var objects: Dictionary = {solid={},goals={},gates={},triggers={}}
var currentFile: String
var conditions: Array[String] = []

var topBound = null
var bottomBound = null
var leftBound = null
var rightBound = null

func _ready():
	get_node("/root/game/ui/levelNumber").text = levelNumber

func init(_currentFile, _game):
	currentFile = _currentFile
	game = _game
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
	
	for cell in %objectGrid .get_used_cells():
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
			if "condition" in object.state and object.state.condition not in conditions:
				conditions.append(object.state.condition)
			objects[layer][actualCell] = object
			add_child(object)
	
	%objectGrid.visible = false
	return self

func loadLevel(level):
	queue_free()
	get_node("/root/game").add_child(load(level).instantiate().init(level, game))

func toNextLevel(): loadLevel(nextLevel)
func restart(): loadLevel(currentFile)

func allObjects():
	var _objects = []
	for layer in objects:
		_objects += objects[layer].values()
	return _objects
