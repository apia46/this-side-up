class_name Box
extends GameObject

static func New(_position: Vector3i, _level: Level, _state:BoxState=BoxState.new()) -> Box:
	var _box = baseNew(preload("res://assets/objects/box/box.tscn").instantiate(), _position, _level, _state)
	_box.state.positionOffset = Vector3(0, 0.5, 0)
	baseNewEnd(_box)
	return _box

func _ready():
	for arrow in %hoverArrows.get_children():
		arrow.play("default")

func hover():
	super()
	for arrow in %hoverArrows.get_children():
		arrow.visible = true

func unhover():
	super()
	for arrow in %hoverArrows.get_children():
		arrow.visible = false

func hold():
	if state.held: return false
	state.held = true
	state.positionOffset = Vector3(0,0.6,0)
	rotation = state.getRotationAsVector()
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	positionTween = create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.promiseState(id, state.position, Level.STATES.BOX_HELD)
	return true

func moveTo(_position: Vector3i, _rotation:=Vector3i(0,0,0), changeHeight:=false):
	print("going to " + str(_position))
	var previousPosition = state.position
	var previousRotation = state.rotation
	
	position = state.getPositionAsVector()
	rotation = state.getRotationAsVector()
	
	# we have to check because of gate bumping. fuckk
	if state.getTileRelative(Vector3i(0,0,0), level.stateGrid) != Level.STATES.SOLID: level.stateGrid.set_cell_item(state.position, Level.STATES.NONE)
	var relativePosition = _position - state.position
	
	if changeHeight:
		state.position.y += _position.y
	else:
		state.position.x = _position.x
		state.position.z = _position.z
	state.rotation += _rotation
	
	if !state.held and isTileNonsolid(getStateOfCellIncludingPromises(state.positionRelative(Vector3i(0,-1,0)))):
		while state.position.y > -5 and isTileNonsolid(getStateOfCellIncludingPromises(state.positionRelative(Vector3i(0,-1,0)))):
			state.position.y -= 1
		var toRotate = Vector3i(0,0,0)
		match sign(relativePosition.x):
			1: toRotate.z = -90
			-1: toRotate.z = 90
		match sign(relativePosition.z):
			1: toRotate.x = 90
			-1: toRotate.x = -90
		#print("=====")
		#print("prerotated", state.rotation)
		#print("torotate", toRotate)
		var aWantForBetterSyntax = state.rotateRotation(toRotate)
		state.rotation = aWantForBetterSyntax[0]
		rotation += Vector3i(aWantForBetterSyntax[1]) * ObjectState.TAU_OVER_360
		#print("rotated", state.rotation)
	
	if state.position != previousPosition: level.addChangeToStack(id, 0, previousPosition)
	if state.rotation != previousRotation: level.addChangeToStack(id, 1, previousRotation)
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	
	rotation += Vector3(state.wrapSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
	#print("wrapped", state.rotation)
	
	positionTween = create_tween()
	rotationTween = create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.promiseState(id, state.position, Level.STATES.BOX_HELD)
	print("went to " + str(state.position))

func drop(_position: Vector3i):
	state.held = false
	state.positionOffset = Vector3(0,0.5,0)
	level.stateGrid.set_cell_item(state.position, Level.STATES.NONE)
	moveTo(_position)
	level.promiseState(id, state.position, Level.STATES.BOX)

func getHoverTitleText(): return "Box"
func getHoverBodyText(): return super() + "Held:" + str(state.held) + "\nFacing:" + ["up","down","north","east","south","west"][state.facing()]

func undoed(property, propertyWas):
	super(property, propertyWas)
	if property == "position":
		level.stateGrid.set_cell_item(propertyWas, Level.STATES.NONE)
		level.promiseState(id, state.position, Level.STATES.BOX_HELD)

func getStateOfCellIncludingPromises(cell:Vector3i) -> Level.STATES:
	for promise in level.statePromises:
		if promise[1] == cell: return promise[2]  as Level.STATES
	return level.stateGrid.get_cell_item(cell) as Level.STATES

func occupiedTiles() -> Array[CollisionCheck.CollisionTile]:
	return [
		CollisionCheck.Tile(state.position, CollisionCheck.COLLISION_TYPES.HELD if state.held else CollisionCheck.COLLISION_TYPES.HOLDABLE, self)
	]
