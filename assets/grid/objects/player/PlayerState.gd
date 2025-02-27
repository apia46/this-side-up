class_name PlayerState
extends ObjectState

var held: Array = []
@export var holding: bool = false
@export var birdseyeCamera: bool = false
@export var high: bool = false

func facing() -> FACING:
	match mod360(rotation.y):
		0: return FACING.EAST
		90: return FACING.NORTH
		180: return FACING.WEST
		_: return FACING.SOUTH
