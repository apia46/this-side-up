class_name Player
extends GameObject

var level: Level

var state: ObjectState
@onready var fork: Fork = %fork
var held: Array[Box] = []
var holding: bool = false

var positionTween: Tween
var rotationTween: Tween

var won: bool = false

var birdseyeCameraPosition: Vector3 = Vector3(0,10,0)
var birdseyeCamera: bool = false
const CAMERA_SPEED: int = 15

const betterControls: bool = true

static func New(_position: Vector3i, _level: Level, _state:=ObjectState.new()) -> Player:
	var _player = baseNew(preload("res://assets/grid/objects/player/player.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_player)
	return _player

func _ready():
	%arrow.play("idle")
	%camera.position = global_transform.origin + %cameraPosition.position

func _process(delta):
	if Input.is_action_pressed("forward") and birdseyeCameraPosition.z >= level.topBound: birdseyeCameraPosition -= Vector3(0,0,CAMERA_SPEED*delta)
	if Input.is_action_pressed("left") and birdseyeCameraPosition.x >= level.leftBound: birdseyeCameraPosition -= Vector3(CAMERA_SPEED*delta,0,0)
	if Input.is_action_pressed("right") and birdseyeCameraPosition.x <= level.rightBound: birdseyeCameraPosition += Vector3(CAMERA_SPEED*delta,0,0)
	if Input.is_action_pressed("backward") and birdseyeCameraPosition.z <= level.bottomBound: birdseyeCameraPosition += Vector3(0,0,CAMERA_SPEED*delta)
	%camera.position += ((birdseyeCameraPosition.snapped(Vector3(1,1,1)) + Vector3(0.5,0,1.2) if birdseyeCamera else global_transform.origin + %cameraPosition.position) - %camera.position) * 0.15
	
	# https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	for object in level.allObjects():
		object.hovered = false
	
	var from = %camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + %camera.project_ray_normal(get_viewport().get_mouse_position()) * %camera.far
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result != {}:
		result.collider.get_parent().hovered = true
	for object in level.allObjects():
		object.processHover()

func _input(event):
	if won: return
	var previousRotation = state.rotation
	
	if event.is_action_pressed("debug"):
		level.stateGrid.visible = !level.stateGrid.visible
	
	if event.is_action_pressed("win"):
		level.toNextLevel()
	
	if event.is_action_pressed("restart"):
		level.restart()
	
	if event.is_action_pressed("toggle_camera"):
		if birdseyeCamera:
			get_tree().create_tween().tween_property(%camera, "rotation", %cameraPosition.rotation, 0.5).set_trans(Tween.TRANS_QUAD)
		else:
			birdseyeCameraPosition = Vector3(state.position) + Vector3(0,10,0)
			#get_tree().create_tween().tween_property(%camera, "rotation", Vector3(-1.41421356,0.883136602,-0.883136602), 0.5).set_trans(Tween.TRANS_QUAD)
			get_tree().create_tween().tween_property(%camera, "rotation", Vector3(-1.5,0,0), 0.5).set_trans(Tween.TRANS_QUAD)
		birdseyeCamera = !birdseyeCamera
	if birdseyeCamera: return
	
	if event is InputEventKey: animateArrow()
	
	if event.is_action_pressed("drop"):
		var objects = 0
		for object in held:
			if isTileSolid(state.getTileRelative(Vector3i(2,objects,0), level.stateGrid, fork.high)): return
		objects = 0
		var highRelative = isTileNonsolid(state.getTileRelative(Vector3i(2,-1,0), level.stateGrid, fork.high))
		for object in held:
			object.drop(state.positionRelative(Vector3i(2 + objects,0,0)))
			if highRelative: objects += 1
		held = []
		holding = false
		endOfTurn()
		return
	
	if level.canLift and event.is_action_pressed("toggle_height"):
		if fork.high:
			if isTileSolid(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
			fork.high = false
			fork.moveTo(Vector3(0,0,0))
			for object in held: object.moveTo(state.positionRelative(Vector3i(0,-1,0)), Vector3i(0,0,0), true)
		else:
			fork.high = true
			fork.moveTo(Vector3(0,1,0))
			for object in held: object.moveTo(state.positionRelative(Vector3i(0,1,0)), Vector3i(0,0,0), true)
	
	if (event.is_action_pressed("movement_better") if betterControls else event.is_action_pressed("movement")):
		position = state.getPositionAsVector()
		rotation = state.getRotationAsVector()
	
	if (event.is_action_pressed("forward") and Input.is_action_pressed("left") if betterControls else event.is_action_pressed("forward_left")):
		if isTileSolid(state.getTileRelative(Vector3i(1,0,-1), level.stateGrid)): return
		if isTileSolid(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(1,0,-2), level.stateGrid, fork.high)): return
		if holding and isTileSolid(state.getTileRelative(Vector3i(1,0,-2), level.stateGrid, fork.high)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(2,0,-1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(1,0,-1))
		state.rotation.y += 90
	elif (event.is_action_pressed("forward") and Input.is_action_pressed("right") if betterControls else event.is_action_pressed("forward_right")):
		if isTileSolid(state.getTileRelative(Vector3i(1,0,1), level.stateGrid)): return
		if isTileSolid(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(1,0,2), level.stateGrid, fork.high)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		if holding and isTileSolid(state.getTileRelative(Vector3i(1,0,2), level.stateGrid, fork.high)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(2,0,1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(1,0,1))
		state.rotation.y += -90
	elif event.is_action_pressed("forward"):
		if isTileSolid(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		if holding and isTileSolid(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(1,0,0))
	elif (event.is_action_pressed("backward") and Input.is_action_pressed("left") if betterControls else event.is_action_pressed("backward_left")):
		if isTileSolid(state.getTileRelative(Vector3i(-1,0,-1), level.stateGrid)): return
		if isTileSolid(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(0,0,1), level.stateGrid, fork.high)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(-1,0,1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(-1,0,-1))
		state.rotation.y += -90
	elif (event.is_action_pressed("backward") and Input.is_action_pressed("right") if betterControls else event.is_action_pressed("backward_right")):
		if isTileSolid(state.getTileRelative(Vector3i(-1,0,1), level.stateGrid)): return
		if isTileSolid(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(0,0,-1), level.stateGrid, fork.high)): return
		#if holding and isTileSolid(state.getTileRelative(Vector3i(-1,0,-1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(-1,0,1))
		state.rotation.y += 90
	elif event.is_action_pressed("backward"):
		if isTileSolid(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		state.moveRotated(Vector3i(-1,0,0))
	else:
		return
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	
	var unfixedRotation = state.rotation
	
	rotation += Vector3(state.wrapSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
	
	positionTween = get_tree().create_tween()
	rotationTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	for object in held:
		object.moveTo(state.positionRelative(Vector3i(1,0,0)), unfixedRotation - previousRotation)
	
	# pick up?
	var offset = Vector3i(0,0,0)
	while state.positionRelative(Vector3i(1,0,0) + offset, fork.high) in level.objects.solid:
		var object = level.objects.solid[state.positionRelative(Vector3i(1,0,0) + offset, fork.high)]
		if object is Box and !object.held:
			held.append(object)
			object.hold()
			holding = true
			offset += Vector3i(0,1,0)
		else: break
	endOfTurn()

static func cantForkInto(checkState:Level.STATES) -> bool:
	return checkState == Level.STATES.SOLID

func win():
	won = true
	await get_tree().create_timer(1.0).timeout
	level.toNextLevel()

func endOfTurn():
	for object in level.objects.goals:
		if !level.objects.goals[object].hasBox(): return
	win()

func animateArrow():
	if Input.is_action_pressed("left"):
		match %arrow.animation:
			"idle": %arrow.play("turn_left")
			"turn_left": %arrow.play("idle_left")
			"turn_right":
				if %arrow.frame == 0:
					%arrow.play("turn_left")
				else: %arrow.play_backwards("turn_right")
			"idle_right": %arrow.play_backwards("turn_right")
	elif Input.is_action_pressed("right"):
		match %arrow.animation:
			"idle": %arrow.play("turn_right")
			"turn_right": %arrow.play("idle_right")
			"turn_left":
				if %arrow.frame == 0:
					%arrow.play("turn_right")
				else: %arrow.play_backwards("turn_left")
			"idle_left": %arrow.play_backwards("turn_left")
	else:
		match %arrow.animation:
			"turn_left":
				if %arrow.frame == 0:
					%arrow.play("idle")
				else: %arrow.play_backwards("turn_left")
			"turn_right":
				if %arrow.frame == 0:
					%arrow.play("idle")
				else: %arrow.play_backwards("turn_right")
			"idle_left": %arrow.play_backwards("turn_left")
			"idle_right": %arrow.play_backwards("turn_right")
	
