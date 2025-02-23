class_name game
extends Node3D

func _ready():
	add_child(preload("res://assets/levels/tutorial.tscn").instantiate().loadLevel("res://assets/levels/tutorial.tscn"))
