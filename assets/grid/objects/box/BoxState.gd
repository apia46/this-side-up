class_name BoxState
extends ObjectState

var held: bool = false

func serialise(): return [super(), held]

func deserialise(values, object):
	object.level.stateGrid.set_cell_item(position, Level.STATES.NONE)
	super(values[0], object)
	held = values[1]
	object.level.promiseState(object.id, position, Level.STATES.BOX_HELD if held else Level.STATES.BOX)

func occupiedPositions() -> Dictionary[Vector3i,Level.COLLISION_TYPES]: return {position:Level.COLLISION_TYPES.SOLID}
