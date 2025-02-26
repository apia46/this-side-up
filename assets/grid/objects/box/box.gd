class_name Box
extends GameObject

var positionTween: Tween
var rotationTween: Tween

static func New(_position: Vector3i, _level: Level, _state:BoxState=BoxState.new()) -> Box:
	var _box = baseNew(preload("res://assets/grid/objects/box/box.tscn").instantiate(), _position, _level, _state)
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
	state.held = true
	state.positionOffset = Vector3(0,0.6,0)
	rotation = state.getRotationAsVector()
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	positionTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX_HELD)

func moveTo(_position: Vector3i, _rotation:=Vector3i(0,0,0), changeHeight:=false):
	position = state.getPositionAsVector()
	rotation = state.getRotationAsVector()
	
	level.stateGrid.set_cell_item(state.position, -1)
	if level.objects.solid[state.position] == self: level.objects.solid.erase(state.position)
	var relativePosition = _position - state.position
	
	if changeHeight:
		state.position.y += _position.y
	else:
		state.position.x = _position.x
		state.position.z = _position.z
	state.rotation += _rotation
	
	if !state.held and isTileNonsolid(state.getTileRelative(Vector3i(0,-1,0), level.stateGrid)):
		while state.position.y > -5 and isTileNonsolid(state.getTileRelative(Vector3i(0,-1,0), level.stateGrid)):
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
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	
	rotation += Vector3(state.wrapSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
	#print("wrapped", state.rotation)
	
	positionTween = get_tree().create_tween()
	rotationTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX_HELD)
	level.objects.solid[state.position] = self

func drop(_position: Vector3i):
	state.held = false
	state.positionOffset = Vector3(0,0.5,0)
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	rotation = state.getRotationAsVector()
	level.stateGrid.set_cell_item(state.position, -1)
	moveTo(_position)
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX)

func getHoverTitleText(): return "Box"
func getHoverBodyText(): return super() + "Facing:" + ["up","down","north","east","south","west"][state.facing()]
