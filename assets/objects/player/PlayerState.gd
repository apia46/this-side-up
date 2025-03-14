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
