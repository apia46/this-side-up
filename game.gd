class_name Game
extends Node3D

const LEVEL_NAMES = {
	"map": "",
	"set1/1": "1-1",
	"set1/2": "1-2",
	"set1/3": "1-3",
	"set1/4": "1-4",
	"set1/5": "1-5",
}

var levelData = {}
var undoStack = []

var debug: bool = false

func _ready():
	add_child(preload("res://assets/levels/map.tscn").instantiate().init("map", self))

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		debug = !debug
