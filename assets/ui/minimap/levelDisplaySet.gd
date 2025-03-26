@tool
class_name LevelDisplaySet
extends Node2D

@export_enum("Up", "Right", "Down", "Left") var direction: int:
	set(value): direction = value; update()
@export_range(1, 10) var number: int = 1:
	set(value): number = value; update()
@export var start: String = "set1/1":
	set(value): start = value; update()
var displays: Array[LevelDisplay] = []

func update():
	for child in get_children(): child.free()
	displays = []
	
	var levelSet = Level.generateLevelSet(start).to_lower()
	var levelNumStart = Level.generateLevelNumber(start)
	levelNumStart = int(levelNumStart) if levelNumStart.is_valid_int() else 0
	for index in number:
		var location
		match direction:
			0: location = Vector2(0, -128 * index)
			1: location = Vector2(128 * index, 0)
			2: location = Vector2(0, 128 * index)
			3: location = Vector2(-128 * index, 0)
		var newDisplay = LevelDisplay.New("set"+levelSet+"/"+str(levelNumStart+index), location)
		displays.append(newDisplay)
		add_child(newDisplay)
