extends Node3D

func _ready():
	loadLevel()

func loadLevel():
	for cell in %objectGrid.get_used_cells():
		var object
		match %objectGrid.get_cell_item(cell):
			0:
				object = Player.New(cell)
		
		if object: add_child(object)
	
	#%objectGrid.visible = false
