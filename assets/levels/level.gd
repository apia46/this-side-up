class_name Level
extends Node3D

enum STATES {
	NONE,
	SOLID,
	BOX,
	BOX_HELD
}

@onready var stateGrid: GridMap = %stateGrid

@export var levelNumber: String
@export_file("*.tscn") var nextLevel: String
@export var canLift: bool = true
@export var data: Dictionary[Vector3i, ObjectState]

var objects: Dictionary = {solid={},goals={}}
var levelId: String

var topBound = null
var bottomBound = null
var leftBound = null
var rightBound = null

func _ready():
	get_node("/root/game/ui/levelNumber").text = levelNumber

func loadLevel(_levelId):
	levelId = _levelId
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
		var object
		var layer = "solid"
		var actualCell = cell
		while %stateGrid.get_cell_item(actualCell - Vector3i(0,1,0)) == -1:
			actualCell -= Vector3i(0,1,0)
		match %objectGrid.get_cell_item(cell):
			0:
				object = Player.New(actualCell, self)
			1:
				if cell in data: object = Box.New(actualCell, self, data[cell])
				else: object = Box.New(actualCell, self)
				%stateGrid.set_cell_item(actualCell, STATES.BOX)
			2:
				object = BoxGoal.New(actualCell, self)
				layer = "goals"
		if object:
			objects[layer][actualCell] = object
			add_child(object)
	
	%objectGrid.visible = false
	
	return self

func toNextLevel():
	get_node("/root/game").add_child(load(nextLevel).instantiate().loadLevel(nextLevel))
	queue_free()

func restart():
	get_node("/root/game").add_child(load(levelId).instantiate().loadLevel(levelId))
	queue_free()

func allObjects():
	var _objects = []
	for layer in objects:
		_objects += objects[layer].values()
	return _objects
