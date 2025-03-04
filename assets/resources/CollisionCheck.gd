class_name CollisionCheck
extends Resource

var tiles: Array[Array] = []
var tileGrid: GridMap
var allObjects: Array[GameObject]
var ownObjects: Array[GameObject]

func _init(_tileGrid:GridMap, _allObjects:Array[GameObject]):
	tileGrid = _tileGrid
	allObjects = _allObjects

func addObjects(objects): # tiles to yourself
	for object in objects:
		ownObjects.append(objects)
		tiles

func checkStraight(vector:Vector3i):
	# can only move one axis at a time
	assert((1 if vector.x else 0) + (1 if vector.y else 0) + (1 if vector.z else 0) == 1)
	var direction = sign(vector)
	var magnitude = vector.x+vector.y+vector.z
	var fails = []
	var workingTiles = tiles.duplicate()
	var workingVector = Vector3i(0,0,0)
	for step in range(magnitude):
		workingVector += direction
		for tile in workingTiles:
			var movingTo = tile[1] + workingVector
			if !canEnter(tile[0], getPosition(movingTo)):
				workingTiles.remove(tile)
				fails.append([tile[1], movingTo])
	if len(fails) == 0: return false
	return fails

func canEnter(type:Level.COLLISION_TYPES, value):
	if value == "empty": return true
	if value == "tile": return false
	assert(value is Array)
	for objectType in value:
		if type == Level.COLLISION_TYPES.FORK and objectType == Level.COLLISION_TYPES.PICKUPABLE: return true
		return objectType == Level.COLLISION_TYPES.SOLID

func getPosition(position:Vector3i):
	var gridTile = tileGrid.get_cell_item(position)
	if gridTile != -1: return "tile"
	var toReturn = []
	for object in allObjects:
		if object in ownObjects: continue
		var occupiedPositions = object.state.occupiedPositions()
		if position in occupiedPositions:
			toReturn.append(occupiedPositions[position])
	if len(toReturn) > 0: return toReturn
	return "empty"
