class_name game
extends Node3D

func _ready():
	add_child(preload("res://assets/levels/map.tscn").instantiate().loadLevel("res://assets/levels/map.tscn"))
