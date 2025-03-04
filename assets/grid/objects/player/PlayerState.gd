class_name PlayerState
extends ObjectState

var held: Array[GameObject] = []
@export var birdseyeCamera: bool = false
@export var high: bool = false

func facing() -> FACING:
	match mod360(rotation.y):
		0: return FACING.EAST
		90: return FACING.NORTH
		180: return FACING.WEST
		_: return FACING.SOUTH

func serialise():
	var heldSerial = []
	for object in held:
		heldSerial.append(object.id)
	return [super(), heldSerial]

func deserialise(values, object):
	super(values[0], object)
	for id in values[1]:
		held.append(object.level.allObjects[int(id)])

func occupiedPositions() -> Dictionary[Vector3i,Level.COLLISION_TYPES]:
	return {position:Level.COLLISION_TYPES.SOLID, positionRelative(Vector3i(1,0,0), high):Level.COLLISION_TYPES.FORK}
