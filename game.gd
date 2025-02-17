class_name game
extends Node3D

func _ready():
	add_child(preload("res://assets/levels/level1.tscn").instantiate().loadLevel())
