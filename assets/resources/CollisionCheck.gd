class_name CollisionCheck

enum COLLISION_TYPES {
	NON_SOLID,
	WALL, # for tiles
	SOLID, # for objects
	HOLDABLE,
	HELD,
	FORK,
}

var ownTiles: Array[CollisionTile] = []
var tileGrid: GridMap
var allObjects: Array[GameObject]
var ownObjects: Array[GameObject]

func _init(_tileGrid:GridMap, _allObjects:Array[GameObject]):
	tileGrid = _tileGrid
	allObjects = _allObjects

## add tile to yourself
func addObject(object):
	if !object: return # the bullshit player held undo ass thing
	ownObjects.append(object)
	ownTiles.append_array(object.occupiedTiles())
	#print(object.occupiedTiles())

## add tiles to yourself
func addObjects(objects):
	for object in objects:
		addObject(object)

## really janky rotate check
## cant rotate 180 degrees.
## returns an array of fails
func checkRotate(angle:Vector3i, center:Vector3i) -> Array[CollisionTile]:
	assert((1 if angle.x else 0) + (1 if angle.y else 0) + (1 if angle.z else 0) == 1)
	var collisions: Array[CollisionTile] = []
	var direction = 1 if angle.x+angle.y+angle.z == 90 else -1
	for ownTile in ownTiles:
		var diff = (ownTile.position - center) * direction
		var checkPosition = center
		if angle.x:
			checkPosition.y += diff.z
			checkPosition.z += diff.y
		elif angle.y:
			checkPosition.x += diff.z
			checkPosition.z += diff.x
		else:
			checkPosition.x += diff.y
			checkPosition.y += diff.x
		ownTile.position = checkPosition
		collisions.append_array(getCollides(ownTile, ownTile.position))
	return collisions

## moves everything in a direction and see what collides
## can only move one axis at a time
## returns an array of fails
func checkDir(vector:Vector3i) -> Array[CollisionTile]:
	assert((1 if vector.x else 0) + (1 if vector.y else 0) + (1 if vector.z else 0) == 1)
	print("checking!")
	var collisions:Array[CollisionTile] = []
	for ownTile in ownTiles:
		ownTile.position += vector
		collisions.append_array(getCollides(ownTile, ownTile.position))
	return collisions

## get array of things colliding with
func getCollides(ownTile:CollisionTile, checkPosition:Vector3i) -> Array[CollisionTile]:
	print("checking ", checkPosition, ", recieved ", getPosition(checkPosition))
	var collisions: Array[CollisionTile] = []
	for checkTile in getPosition(checkPosition):
		if checkTile.object not in ownObjects and !canEnter(ownTile.collisionType, checkTile.collisionType): collisions.append(checkTile)
	return collisions

## logic for if a certain collision type should be able to enter a collision type
func canEnter(selfType:COLLISION_TYPES, checkType:COLLISION_TYPES) -> bool:
	if checkType == COLLISION_TYPES.NON_SOLID: return true
	if selfType == COLLISION_TYPES.FORK and checkType == COLLISION_TYPES.HOLDABLE: return true
	return false

## get the collisionTiles that are in a position from the tilemap or from objects, ignoring own objects
func getPosition(position:Vector3i) -> Array[CollisionTile]:
	var tile: Array[CollisionTile] = []
	for object in allObjects:
		for collisionTile in object.occupiedTiles():
			if collisionTile.position == position: tile.append(collisionTile)
	if tileGrid.get_cell_item(position) != -1: tile.append(Tile(position, COLLISION_TYPES.WALL))
	return tile

static func Tile(position:Vector3i, collisionType:COLLISION_TYPES, object:GameObject=null) -> CollisionTile:
	return CollisionTile.new(position, collisionType, object)
class CollisionTile:
	var position: Vector3i
	var collisionType: COLLISION_TYPES
	var object: GameObject
	
	func _init(_position:Vector3i, _collisionType:COLLISION_TYPES, _object:GameObject=null):
		position = _position
		collisionType = _collisionType
		object = _object
	
	func _to_string():
		return "<CollisionTile: " + str(position) + ", " + COLLISION_TYPES.keys()[collisionType] + ", " + str(object) + ">"
