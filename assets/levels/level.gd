class_name Level
extends Node3D

@onready var stateGrid = %stateGrid

enum STATES {
	EMPTY,
	SOLID,
	BOX
}

func _ready():
	loadLevel()

func loadLevel():
	for cell in %tileGrid.get_used_cells():
		match %tileGrid.get_cell_item(cell):
			0: # wall
				%stateGrid.set_cell_item(cell, STATES.SOLID)
		
	for cell in %objectGrid.get_used_cells():
		var object
		match %objectGrid.get_cell_item(cell):
			0:
				object = Player.New(cell, self)
			1:
				object = Box.New(cell, self)
				%stateGrid.set_cell_item(cell, STATES.BOX)
		if object: add_child(object)
	
	#%objectGrid.visible = false
