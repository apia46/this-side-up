@tool
class_name LevelDisplaySet
extends Node2D

@export_enum("Up", "Right", "Down", "Left") var direction: int:
	set(value):
		direction = value
		update()
@export var number: int = 1:
	set(value):
		number = value
		update()
@export var offset: int = 160:
	set(value):
		offset = value
		update()

func update():
	print("mrow")
