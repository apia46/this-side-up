class_name Gate
extends GameObject

static func New(_position: Vector3i, _level: Level, _state:=GateState.new()) -> Gate:
	var _gate = baseNew(preload("res://assets/grid/objects/gate/gate.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_gate)
	return _gate

func open():
	if state.open: return
	state.open = true
	get_tree().create_tween().tween_property(%gate, "position:y", -0.5, 0.1)
	level.stateGrid.set_cell_item(state.position, Level.STATES.NONE)
	var overlap = level.getObject("solid", state.position + Vector3i(0,1,0))
	if overlap and overlap is Box: overlap.moveTo(Vector3i(0,-1,0), Vector3i(0,0,0), true)
	%collision.set_collision_layer_value(1, false)

func close():
	if !state.open: return
	state.open = false
	get_tree().create_tween().tween_property(%gate, "position:y", 0.5, 0.1)
	level.stateGrid.set_cell_item(state.position, Level.STATES.SOLID)
	var overlap = level.getObject("solid", state.position)
	if overlap and overlap is Box: overlap.moveTo(Vector3i(0,1,0), Vector3i(0,0,0), true)
	%collision.set_collision_layer_value(1, true)

func getHoverTitleText(): return "Gate"
func getHoverBodyText():
	return super() +\
	"Condition:" + ( "level[" + Game.LEVEL_INFO[state.condition][0] + "]" if state.condition in Game.LEVEL_INFO\
	else state.condition + "["+str(level.currentConditions[state.condition])+"/"+str(level.conditions[state.condition])+"]")

func occupiedTiles() -> Array[CollisionCheck.CollisionTile]:
	return [
		CollisionCheck.Tile(state.position, CollisionCheck.COLLISION_TYPES.SOLID, self)
	]
