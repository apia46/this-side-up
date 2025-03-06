class_name Hover
extends PanelContainer

@onready var ui = get_node("/root/game/ui")
@onready var title = get_node("MarginContainer/VBoxContainer/title")
@onready var body = get_node("MarginContainer/VBoxContainer/body")

func _ready():
	modulate.a = 0

func _process(_delta):
	position = get_viewport().get_mouse_position() + Vector2(10, 0)
	if get_viewport().get_mouse_position().x > size.x and get_viewport().get_mouse_position().x + size.x + 10 > ui.size.x:
		position.x -= size.x + 10
	if get_viewport().get_mouse_position().y > size.y and get_viewport().get_mouse_position().y + size.y > ui.size.y:
		position.y -= size.y
	size = Vector2(0,0)
