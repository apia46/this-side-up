extends Node2D

@onready var game = get_node("/root/game")
var displays: Array[LevelDisplay] = []

func _ready():
	for child in get_children():
		if child is LevelDisplay: displays.append(child)
		elif child is LevelDisplaySet: displays.append_array(child.displays)

func _input(event):
	if game.hoveringMinimap and event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			position += event.relative

func _process(delta):
	var sizeDiff = (0.4 - scale.x) * delta * 2
	position -= Vector2(64,64)
	position *= 1+sizeDiff/scale.x
	position += Vector2(64,64)
	scale += Vector2(sizeDiff, sizeDiff)

func go(level:String):
	var startDisplay : LevelDisplay
	for display in displays:
		if display.level == level:
			startDisplay = display
	if !startDisplay:
		position = Vector2(-26, -28)
	else:
		position = Vector2(-26, -28) - startDisplay.position - startDisplay.get_parent().position
	scale = Vector2(1,1)
