class_name Player
extends GameObject

@onready var fork: Fork = %fork
@onready var confirmCircle = game.ui.confirmCircle

var confirmStatus: String = "restart"

var hoveringAnything: bool = false

var birdseyeCameraPosition: Vector3 = Vector3(0,10,0)
const CAMERA_SPEED: int = 15

const betterControls: bool = true

var positionComponent1: Vector3
var positionComponent2: Vector3

static func New(_position: Vector3i, _level: Level, _state:=PlayerState.new()) -> Player:
	var _player = baseNew(preload("res://assets/objects/player/player.tscn").instantiate(), _position, _level, _state)
	if _level.levelData.spawnRotation != Vector3i(0,-1,0): _player.state.rotation = _level.levelData.spawnRotation
	baseNewEnd(_player)
	return _player

func _ready():
	if Input.is_action_pressed("restart"): confirmStatus = "held"
	%arrow.play("idle")
	%camera.position = global_transform.origin + %cameraPosition.position

func _process(delta):
	#position = positionComponent1 + positionComponent2
	
	if game.won != 1 and Input.is_action_pressed("forward") and birdseyeCameraPosition.z >= level.topBound: birdseyeCameraPosition -= Vector3(0,0,CAMERA_SPEED*delta)
	if game.won != 1 and Input.is_action_pressed("left") and birdseyeCameraPosition.x >= level.leftBound: birdseyeCameraPosition -= Vector3(CAMERA_SPEED*delta,0,0)
	if game.won != 1 and Input.is_action_pressed("right") and birdseyeCameraPosition.x <= level.rightBound: birdseyeCameraPosition += Vector3(CAMERA_SPEED*delta,0,0)
	if game.won != 1 and Input.is_action_pressed("backward") and birdseyeCameraPosition.z <= level.bottomBound: birdseyeCameraPosition += Vector3(0,0,CAMERA_SPEED*delta)
	%camera.position += ((birdseyeCameraPosition.snapped(Vector3(1,1,1)) + Vector3(0.5,0,1.2) if state.birdseyeCamera else global_transform.origin + %cameraPosition.position) - %camera.position) * 0.15
	
	# https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	for object in level.allObjects:
		object.hovered = false
	var result = {}
	if !game.hoveringMinimap:
		var from = %camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + %camera.project_ray_normal(get_viewport().get_mouse_position()) * %camera.far
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		result = get_world_3d().direct_space_state.intersect_ray(query)
		if result != {}:
			result.collider.get_parent().hovered = true
	else:
		if game.minimapHover:
			result = {"":""} # really fucked up
			hoverPopup.body.text = ""
			hoverPopup.body.text = ("Cleared" if game.minimapHover.visited and game.levelData[game.minimapHover.level].won else "Uncleared")
			if game.minimapHover.level in Game.LEVEL_INFO:
				hoverPopup.title.text = game.minimapHover.levelText + ": " + Game.LEVEL_INFO[game.minimapHover.level][1]
				if len(Game.LEVEL_INFO[game.minimapHover.level]) > 2: hoverPopup.body.text += "\nAuthor: " + Game.LEVEL_INFO[game.minimapHover.level][2]
				if Game.LEVEL_INFO[game.minimapHover.level][0][-1] == "!": hoverPopup.body.text += "\nSecret"
			else:
				hoverPopup.title.text = game.minimapHover.levelText
				hoverPopup.body.text += "\nAutogenerated"
	for object in level.allObjects:
		object.processHover()
	if hoveringAnything or hoverPopup.modulate.a == 1: if result == {}: create_tween().tween_property(hoverPopup, "modulate:a", 0, 0.2).set_ease(Tween.EASE_OUT)
	elif result != {}: get_tree().create_tween().tween_property(hoverPopup, "modulate:a", 1, 0.2).set_ease(Tween.EASE_OUT)
	hoveringAnything = result != {}
	
	if confirmStatus == "held":
		confirmCircle.value -= delta*500
		if !Input.is_action_pressed("restart"): confirmStatus = "restart"
	elif confirmStatus != "confirmed":
		if Input.is_action_pressed("escape") and level.currentFile != "map":
			if confirmStatus != "escape": confirmCircle.value = 0
			confirmStatus = "escape"
		elif game.won != 1 and Input.is_action_pressed("restart"):
			if confirmStatus != "restart": confirmCircle.value = 0
			confirmStatus = "restart"
	if confirmStatus == "escape":
		if Input.is_action_pressed("escape"): confirmCircle.value += delta * 100
		else: confirmCircle.value -= delta*500
		if confirmCircle.value == 100:
			confirmStatus = "confirmed"
			print("ACTION:escape")
			level.changeLevel("map", "escape")
	elif confirmStatus == "restart":
		if game.won != 1 and Input.is_action_pressed("restart"): confirmCircle.value += delta * 200
		else: confirmCircle.value -= delta*500
		if confirmCircle.value == 100:
			confirmStatus = "confirmed"
			print("ACTION:restart")
			level.restart()

func _unhandled_input(event):
	if game.won == 1: return
	if level.inputOverride: return
	var previousPosition = state.position
	var previousRotation = state.rotation
	
	if event.is_action_pressed("toggle_states") and game.debug:
		print("ACTION:toggle_states")
		level.stateGrid.visible = !level.stateGrid.visible
	
	if event.is_action_pressed("win") and game.debug:
		print("ACTION:win")
		level.win()
	
	if event.is_action_pressed("toggle_camera") and (level.canFreecam or game.debug):
		print("ACTION:toggle_camera")
		if state.birdseyeCamera:
			create_tween().tween_property(%camera, "rotation", %cameraPosition.rotation, 0.5).set_trans(Tween.TRANS_QUAD)
		else:
			birdseyeCameraPosition = Vector3(state.position) + Vector3(0,10,0)
			#create_tween().tween_property(%camera, "rotation", Vector3(-1.41421356,0.883136602,-0.883136602), 0.5).set_trans(Tween.TRANS_QUAD)
			create_tween().tween_property(%camera, "rotation", Vector3(-1.5,0,0), 0.5).set_trans(Tween.TRANS_QUAD)
		state.birdseyeCamera = !state.birdseyeCamera
	if state.birdseyeCamera: return
	
	if event is InputEventKey: animateArrow()
	
	var collisionCheck = CollisionCheck.new(level.tileGrid, level.allObjects)
	
	if event.is_action_pressed("drop"):
		if !state.held: return
		print("ACTION:drop")
		var objects = 0
		for object in state.held: object.invertHeldState = true
		collisionCheck.addObjects(state.held)
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(1,0,0)))):
			for object in state.held: object.invertHeldState = false
			return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE1)
		objects = 0
		var highRelative = !collisionCheck.moveDir(Vector3i(0,-1,0), true, false)
		for object in state.held:
			object.invertHeldState = false
			object.drop(state.positionRelative(Vector3i(2 + objects,0,0)))
			if highRelative: objects += 1
		state.held.reverse()
		for object in state.held: level.addChangeToStack(id, 2, ["drop", object.id])
		state.held.clear()
		endOfTurn()
		return
	collisionCheck.addObjects(state.held)
	collisionCheck.addTile(self, getFork())
	if (level.canLift or level.currentFile == "map" and game.flags.unlockLift) and event.is_action_pressed("toggle_height"):
		print("ACTION:toggle_height")
		if state.high:
			if collideResponse(collisionCheck.moveDir(Vector3i(0,-1,0), true, true, true)): return
			state.high = false
			fork.moveTo(Vector3(0,0,0))
			for object in state.held: object.moveTo(Vector3i(0,-1,0), Vector3i(0,0,0), true)
		else:
			if collideResponse(collisionCheck.moveDir(Vector3i(0,1,0))): return
			state.high = true
			fork.moveTo(Vector3(0,1,0))
			for object in state.held: object.moveTo(Vector3i(0,1,0), Vector3i(0,0,0), true)
		level.addChangeToStack(id, 3, !state.high)
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE1)
		return
	
	if event.is_action_pressed("undo"):
		print("ACTION:undo")
		game.undo()
	
	if (event.is_action_pressed("movement_better") if betterControls else event.is_action_pressed("movement")):
		position = state.getPositionAsVector()
		rotation = state.getRotationAsVector()
	else: return
	collisionCheck.addTile(self, getBody())
	if (event.is_action_pressed("forward") and Input.is_action_pressed("left") if betterControls else event.is_action_pressed("forward_left")):
		collisionCheck.moveDir(state.positionRotated(Vector3i(1,0,0)), false)
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.GREEN)
		if collideResponse(collisionCheck.moveRotate(Vector3i(0,90,0), state.positionRelative(Vector3i(1,0,0)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE2)
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(0,0,-1)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE3)
		
		print("ACTION:forward_left")
		state.moveRotated(Vector3i(1,0,-1))
		state.rotation.y += 90
	elif (event.is_action_pressed("forward") and Input.is_action_pressed("right") if betterControls else event.is_action_pressed("forward_right")):
		collisionCheck.moveDir(state.positionRotated(Vector3i(1,0,0)), false)
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.GREEN)
		if collideResponse(collisionCheck.moveRotate(Vector3i(0,270,0), state.positionRelative(Vector3i(1,0,0)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE2)
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(0,0,1)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE3)
		
		print("ACTION:forward_right")
		state.moveRotated(Vector3i(1,0,1))
		state.rotation.y += -90
	elif event.is_action_pressed("forward"):
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(1,0,0)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE1)
		
		print("ACTION:forward")
		state.moveRotated(Vector3i(1,0,0))
	elif (event.is_action_pressed("backward") and Input.is_action_pressed("left") if betterControls else event.is_action_pressed("backward_left")):
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(-1,0,0)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE1)
		collisionCheck.moveRotate(Vector3i(0,270,0), state.positionRelative(Vector3i(-1,0,0)), false)
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.GREEN)
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(0,0,-1)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE3)
		
		print("ACTION:backward_left")
		state.moveRotated(Vector3i(-1,0,-1))
		state.rotation.y += -90
	elif (event.is_action_pressed("backward") and Input.is_action_pressed("right") if betterControls else event.is_action_pressed("backward_right")):
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(-1,0,0)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE1)
		collisionCheck.moveRotate(Vector3i(0,90,0), state.positionRelative(Vector3i(-1,0,0)), false)
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.GREEN)
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(0,0,1)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE3)
		
		print("ACTION:backward_right")
		state.moveRotated(Vector3i(-1,0,1))
		state.rotation.y += 90
	elif event.is_action_pressed("backward"):
		if collideResponse(collisionCheck.moveDir(state.positionRotated(Vector3i(-1,0,0)))): return
		if game.debug: collideResponse(collisionCheck.ownTiles, CantInto.COLORS.BLUE1)
		
		print("ACTION:backward")
		state.moveRotated(Vector3i(-1,0,0))
	else:
		return
	
	# fall
	var fallTo = 0
	while fallTo + state.position.y > -5 and !collisionCheck.moveDir(Vector3i(0,-1,0), true, true, true):
		print("ACTION:FALL")
		fallTo -= 1
	var bodyCheck = CollisionCheck.new(level.tileGrid, level.allObjects)
	bodyCheck.addTile(self, getBody())
	if !bodyCheck.moveDir(Vector3i(0, fallTo-1, 0)):
		collideResponse(collisionCheck.getCurrentlyCollided())
		state.position = previousPosition
		state.rotation = previousRotation
		print("ACTION:CANCELLED")
		return
	
	# pick up collision
	var offset = Vector3i(0,0,0)
	var objectsToHold = []
	while level.getObject("solid", state.positionRelative(Vector3i(1,0,0) + offset, state.high)):
		var object = level.getObject("solid", state.positionRelative(Vector3i(1,0,0) + offset, state.high))
		if object is Box and !object.state.held:
			offset += Vector3i(0,1,0)
			object.invertHeldState = true
			objectsToHold.append(object)
		else: break
	var holdCollisionCheck = CollisionCheck.new(level.tileGrid, level.allObjects)
	holdCollisionCheck.addObjects(objectsToHold)
	var response = collideResponse(holdCollisionCheck.checkHere())
	for object in (objectsToHold): object.invertHeldState = false
	if response:
		state.position = previousPosition
		state.rotation = previousRotation
		print("ACTION:CANCELLED")
		return
	for object in objectsToHold:
			object.invertHeldState = false
	 
	if state.position != previousPosition: level.addChangeToStack(id, 0, previousPosition)
	if state.rotation != previousRotation: level.addChangeToStack(id, 1, previousRotation)
	
	if fallTo: moveRelative(Vector3i(0,fallTo, 0))
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	
	var unfixedRotation = state.rotation
	
	rotation += Vector3(state.wrapSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
	
	positionTween = create_tween()
	rotationTween = create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	for object in state.held:
		object.moveTo(state.positionRelative(Vector3i(1,0,0)), unfixedRotation - previousRotation)
	
	# pick up
	offset = Vector3i(0,0,0)
	for object in objectsToHold:
		state.held.append(object)
		if (object.hold(state.held)): level.addChangeToStack(id, 2, ["hold", object.id])
	
	if game.won == 2: game.ui.winContainer.visible = false
	endOfTurn()

func moveRelative(vector:Vector3i):
	var previousPosition = state.position
	state.position += vector
	for object in state.held:
		object.moveTo(state.positionRelative(vector) if !vector.y else vector,Vector3i(0,0,0),!!vector.y)
	level.addChangeToStack(id, 0, previousPosition)
	if positionTween and positionTween.is_running(): positionTween.kill()
	positionTween = create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

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

func endOfTurn():
	level.turnCount += 1
	print("ACTION:end_of_turn")
	level.fulfillStatePromises()
	level.processConditions()
	processTriggers()
	#print(game.undoStack)

func processTriggers():
	for trigger in level.objects.triggers:
		if trigger.inRange(state.position):
			if trigger.state is TriggerSetSpawn:
				level.levelData.spawnLocation = trigger.state.position
				level.levelData.spawnRotation = trigger.state.rotation

func getHoverTitleText(): return "Player"
func getHoverBodyText(): return super()\
	+ "Facing:" + ["up","down","north","east","south","west"][state.facing()]\
	+ ("\nFork:" + ("lifted" if state.high else "lowered") if game.flags.unlockLift else "")\
	+ ("\nHeld:nothing" if !state.held else "\nHeld:" + getHeldAsText())

func getHeldAsText() -> String:
	var objects = []
	if len(state.held) == 1: return state.held[0].getHoverTitleText()
	for object in state.held:
		if !objects or objects[-1][1] != object.getHoverTitleText(): objects.append([1, object.getHoverTitleText()])
		else: objects[-1][0] += 1
	var toReturn = ""
	for object in objects:
		toReturn += "\n - " + str(object[0]) + "x " + object[1]
	return toReturn

func undoed(property, _propertyWas):
	super(property, _propertyWas)
	if property == "high":
		fork.moveTo(Vector3(0,1 if state.high else 0,0), true)

func specialUndo(event):
	match event[0]:
		"hold":
			for index in len(state.held):
				if state.held[index] and state.held[index].id == event[1]:
					var object = state.held[index]
					state.held[index] = null
					object.drop(object.state.position)
		"drop":
			var object = level.allObjects[int(event[1])]
			state.held.append(object)
			object.hold(state.held)

func undoCleanup():
	super()
	%camera.position = global_transform.origin + %cameraPosition.position
	var iter = 0
	while iter < len(state.held):
		if !state.held[iter]:
			state.held.pop_at(iter)
			iter -= 1
		iter += 1
	state.held.sort_custom(func(a,b): return a.state.position.y < b.state.position.y)

func occupiedTiles() -> Array[CollisionCheck.CollisionTile]:
	return [getBody(), getFork()]
func getBody() -> CollisionCheck.CollisionTile: return CollisionCheck.Tile(state.position, CollisionCheck.COLLISION_TYPES.SOLID, self)
func getFork() -> CollisionCheck.CollisionTile: return CollisionCheck.Tile(state.positionRelative(Vector3i(1,0,0), state.high), CollisionCheck.COLLISION_TYPES.FORK, self)

func collideResponse(collisions:Array[CollisionCheck.CollisionTile], color:Color=CantInto.COLORS.RED) -> bool:
	#print("collide: ", collisions)
	get_tree().call_group("cantIntoEphemeral", "queue_free")
	for collision in collisions:
		#assert(collision.collidedWith)
		if collision.collidedWith:
			level.add_child(CantInto.New(state.getPositionAsVector(collision.originalPosition), state.getPositionAsVector(collision.collidedWith[0].position)))
		else: 
			level.add_child(CantInto.New(state.getPositionAsVector(collision.originalPosition), state.getPositionAsVector(collision.position), 0.7, color, true))
	return !!collisions
