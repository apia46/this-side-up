class_name ObjectState
extends Resource

const TAU_OVER_360 = 0.0174532925

@export var position: Vector3i
@export var rotation: Vector3i
@export var positionOffset: Vector3

func _init(_position = Vector3i(0,0,0), _rotation = 0, _positionOffset = Vector3(0,0,0)):
	position = _position
	rotation.y = _rotation
	positionOffset = _positionOffset

func moveRotated(vector:Vector3i) -> void:
	position += rotatePosition(vector)

func getPositionAsVector() -> Vector3:
	return Vector3(position) + Vector3(0.5, 0, 0.5) + positionOffset

func getRotationAsVector() -> Vector3:
	return Vector3(rotation) * TAU_OVER_360
 
func getTileRelative(location:Vector3i, stateGrid:GridMap, lifted:=false) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(positionRelative(location, lifted))) # cast this somehow

func getTile(location:Vector3i, stateGrid:GridMap) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(location)) # cast this somehow

func rotatePosition(vector:Vector3i) -> Vector3i:
	var result = Vector3i(0,0,0)
	result.y = vector.y
	match rotation.y:
		0:
			result.x = vector.x
			result.z = vector.z
		90:
			result.x = vector.z
			result.z = -vector.x
		180:
			result.x = -vector.x
			result.z = -vector.z
		270:
			result.x = -vector.z
			result.z = vector.x
	return result

func rotateRotation(vector:Vector3i) -> Vector3i:
	# can only rotate one axis at a time
	assert((1 if vector.x else 0) + (1 if vector.y else 0) + (1 if vector.z else 0) == 1)
	var result = rotation
	if vector.y:
		result.y = vector.y
	elif vector.x:
		match rotation.y:
			0: result.x += vector.x
			90: result.z += vector.x
			180: result.x -= vector.x
			270: result.z -= -vector.x
	elif vector.z:
		match rotation.x:
			0, 180:
				var flip = -1 if rotation.x == 180 else 1
				match rotation.y:
					0: result.z += vector.z * flip
					90: result.x -= vector.z
					180: result.z -= vector.z * flip
					270: result.x += vector.z
			90, 270:
				match rotation.y:
					0, 180:
						print("unfixed rotation")
						assert(false)
					90: result.x += -vector.z
					270: result.x += vector.z
	return result

func wrapRotation(vector) -> Vector3i:
	var result = vector
	while result.x > 270:
		result.x -= 360
	while result.x < 0:
		result.x += 360
	
	while result.y > 270:
		result.y -= 360
	while result.y < 0:
		result.y += 360
	
	while result.z > 270:
		result.z -= 360
	while result.z < 0:
		result.z += 360
	return result

func wrapSelfRotation(vector) -> Vector3i:
	var fixed = wrapRotation(vector)
	rotation = fixed
	return fixed - vector

func fixRotation(vector) -> Vector3i:
	var result = vector
	if vector.y % 360 == 90:
		if vector.x % 360 == 90: result = Vector3i(90, 0, [270,0,90,180][(vector.z%360)/90])
		elif vector.x % 360 == 270: result = Vector3i(270, 180, [270,0,90,180][(vector.z%360)/90])
		else: result = vector
	
	if vector.x % 360 == 90:
		result.y = 90
		if vector.y % 360 == 0: result.z += 90
		elif vector.y % 360 == 180: result.z -= 90
		else: result.y = vector.y
	if vector.x % 360 == 270:
		result.y = 270
		if vector.y % 360 == 0: result.z += 90
		elif vector.y % 360 == 180: result.z -= 90
		else: result.y = vector.y
	return result

func fixSelfRotation(vector) -> Vector3i:
	var fixed = fixRotation(vector)
	rotation = fixed
	print("difference", fixed - vector)
	return fixed - vector


func positionRelative(location:Vector3i, lifted:=false) -> Vector3i:
	return rotatePosition(location) + position  + (Vector3i(0,0,0) if !lifted else Vector3i(0,1,0))
