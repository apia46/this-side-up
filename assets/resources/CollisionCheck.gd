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
var ignoredObjects: Array[GameObject]

func _init(_tileGrid:GridMap, _allObjects:Array[GameObject]):
	tileGrid = _tileGrid
	allObjects = _allObjects

## add tile to yourself
func addObject(object):
	if !object: return # the bullshit player held undo ass thing
	if object not in ignoredObjects: ignoredObjects.append(object)
	ownTiles.append_array(object.occupiedTiles())
	#print(object.occupiedTiles())

## add tiles to yourself
func addObjects(objects):
	for object in objects:
		addObject(object)

## add ignored object
func addIgnore(object): if object not in ignoredObjects: ignoredObjects.append(object)
## add ignored objects
func addIgnores(objects): for object in objects: addIgnore(object)

## really janky rotate check
## cant rotate 180 degrees.
## returns an array of fails
func moveRotate(angle:Vector3i, center:Vector3i, check:=true) -> Array[CollisionTile]:
	assert((1 if angle.x else 0) + (1 if angle.y else 0) + (1 if angle.z else 0) == 1)
	var collisions: Array[CollisionTile] = []
	var direction = 1 if angle.x+angle.y+angle.z == 90 else -1
	for ownTile in ownTiles:
		var diff = (ownTile.position - center)
		print(diff)
		diff *= direction
		var checkPosition = center
		if angle.x:
			checkPosition.x = ownTile.position.x
			checkPosition.y += diff.z
			checkPosition.z -= diff.y
		elif angle.y:
			checkPosition.x += diff.z
			checkPosition.y = ownTile.position.y
			checkPosition.z -= diff.x
		else:
			checkPosition.x += diff.y
			checkPosition.y -= diff.x
			checkPosition.z = ownTile.position.z
		ownTile.collidedWith.clear() # clear previous. i assume we want this
		ownTile.position = checkPosition
		if check: collisions.append_array(getCollides(ownTile, ownTile.position))
	return collisions

## moves everything in a direction and see what collides
## can only move one axis at a time
## returns an array of fails
func moveDir(vector:Vector3i, check:=true, move:=true) -> Array[CollisionTile]:
	assert((1 if vector.x else 0) + (1 if vector.y else 0) + (1 if vector.z else 0) == 1)
	#print("checking!")
	var collisions:Array[CollisionTile] = []
	for ownTile in ownTiles:
		ownTile.collidedWith.clear() # clear previous. i assume we want this
		if check: collisions.append_array(getCollides(ownTile, ownTile.position+vector))
		if move: ownTile.position += vector
	return collisions

## get array of things colliding with
func getCollides(ownTile:CollisionTile, checkPosition:Vector3i) -> Array[CollisionTile]:
	#print("checking ", checkPosition, ", recieved ", getPosition(checkPosition))
	var collisions: Array[CollisionTile] = []
	for checkTile in getPosition(checkPosition):
		if checkTile.object not in ignoredObjects and !canEnter(ownTile.collisionType, checkTile.collisionType):
			ownTile.collidedWith.append(checkTile)
			collisions.append(ownTile)
	return collisions

## logic for if a certain collision type should be able to enter a collision type
func canEnter(selfType:COLLISION_TYPES, checkType:COLLISION_TYPES) -> bool:
	if checkType == COLLISION_TYPES.NON_SOLID: return true
	if selfType == COLLISION_TYPES.FORK and checkType == COLLISION_TYPES.HOLDABLE: return true
	if selfType == COLLISION_TYPES.HELD and checkType == COLLISION_TYPES.FORK: return true
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
	var originalPosition: Vector3i
	var collisionType: COLLISION_TYPES
	var object: GameObject
	var collidedWith: Array[CollisionTile] = []
	
	func _init(_position:Vector3i, _collisionType:COLLISION_TYPES, _object:GameObject=null):
		position = _position
		originalPosition = _position
		collisionType = _collisionType
		object = _object
	
	func _to_string():
		return "<CollisionTile: " + str(originalPosition) + (" -> " + str(position) if position != originalPosition else "") + ", " + COLLISION_TYPES.keys()[collisionType] + (", " + str(object) if object else "") + (", against " + str(collidedWith) if len(collidedWith) > 0 else "") + ">"
