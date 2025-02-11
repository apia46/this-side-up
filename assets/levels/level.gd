class_name Level
extends Node3D

enum STATES {
	NONE,
	SOLID,
	BOX,
	BOX_HELD
}

@onready var stateGrid: GridMap = %stateGrid

var objects = {}

func _ready():
	loadLevel()

func loadLevel():
	for cell in %tileGrid.get_used_cells():
		match %tileGrid.get_cell_item(cell):
			0: # wall
				%stateGrid.set_cell_item(cell, STATES.SOLID)
			1: # halfwall
				%stateGrid.set_cell_item(cell, STATES.SOLID)
		
	for cell in %objectGrid.get_used_cells():
		var object
		match %objectGrid.get_cell_item(cell):
			0:
				object = Player.New(cell, self)
			1:
				object = Box.New(cell, self)
				%stateGrid.set_cell_item(cell, STATES.BOX)
		if object:
			objects[cell] = object
			add_child(object)
	
	#%objectGrid.visible = false
