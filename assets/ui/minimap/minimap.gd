extends Node2D

@onready var game = get_node("/root/game")
var displays: Array[LevelDisplay] = []
var previousMousePosition : Vector2

func _ready():
	for child in get_children():
		if child is LevelDisplay: displays.append(child)
		elif child is LevelDisplaySet: displays.append_array(child.displays)

func _process(delta):
	if game.hoveringMinimap and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position += get_viewport().get_mouse_position() - previousMousePosition
	var sizeDiff = (0.6 - scale.x) * delta * 2
	position -= Vector2(64,64)
	position *= 1+sizeDiff/scale.x
	position += Vector2(64,64)
	scale += Vector2(sizeDiff, sizeDiff)
	previousMousePosition = get_viewport().get_mouse_position()

func go(level:String):
	var startDisplay : LevelDisplay
	for display in displays:
		if display.level == level:
			startDisplay = display
	scale = Vector2(1,1)
	if !startDisplay:
		position = Vector2(-26, -28)
	else:
		position = Vector2(-26, -28) - startDisplay.position
		if startDisplay.get_parent() is LevelDisplaySet: position -= startDisplay.get_parent().position
