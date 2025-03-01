class_name LevelData
extends Node

@export var spawnLocation: Vector3i = Vector3i(0,-1,0)
@export var spawnRotation: Vector3i = Vector3i(0,-1,0)
@export var won: bool = false
@export var serial: Array = []
@export var selectBoxLevels: Dictionary[String, Array] = {}
