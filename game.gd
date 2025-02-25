class_name Game
extends Node3D

var levelData = {}

func _ready():
	add_child(preload("res://assets/levels/map.tscn").instantiate().init("res://assets/levels/map.tscn", self))
