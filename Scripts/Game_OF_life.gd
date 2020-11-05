extends Node2D

var grid = {} # dictionary to hold all the cells

export var width 		: int= 10	# total cells wide
export var height 		: int= 10	# total cells tall
export var cell_size 	: int= 32	# width/height of the graphic in pixels
export var spawn_rate 	: int= 50	# percentage to start living
var spacer 				: int = 5	# distance between cells

var start_position	# position to start the grid
var step_timer		# time between each step
var reset_button

var cell = preload("res://scenes/cell.tscn")

func _ready():
	init_nodes()
	init_connections()
	init_grid()
	randomize_grid()
		
func init_nodes():
	start_position = get_node("StartPosition")
	step_timer = get_node("StepTimer")
	reset_button = get_node("ResetButton")
	
func init_connections():
	reset_button.connect("pressed", self, "_on_reset_pressed")
	step_timer.connect("timeout", self, "_on_step_timer_timeout")

func _on_step_timer_timeout():
	run_generation()
	
func _on_reset_pressed():
	randomize_grid()

func init_grid():
	for x in width:
		for y in height:
			var new_cell = cell.instance()
			new_cell.initialize_cell(Vector2(x,y))
			new_cell.rect_position = Vector2(
				start_position.position.x + x*(cell_size + spacer),
				start_position.position.y + y*(cell_size + spacer))
			add_child(new_cell)
			grid[Vector2(x, y)] = new_cell

func randomize_grid():
	randomize()
	for x in width:
		for y in height:
			var temp_cell = grid[Vector2(x, y)]
			if rand_range(1, 101) <= spawn_rate:
				temp_cell.set_status(1)
			else:
				cell.set_status(0)

# Conway's Rules:
	#	Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
	#	Any live cell with two or three live neighbours lives on to the next generation.
	#	Any live cell with more than three live neighbours dies, as if by overpopulation.
	#	Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
	
func run_generation():
	var stats = []
	for x in width:
		for y in height:
			cell = grid[Vector2(x,y)]
			var living_neighbors : int = get_living_neighbors(cell)
			var temp = 0
			if cell.get_status() == 1:
				if living_neighbors <= 1 or living_neighbors >= 4:
					temp = 0
				elif living_neighbors == 2 or living_neighbors == 3:
					temp = 1
			elif cell.get_status() == 0 and living_neighbors == 3:
				temp = 1
			# Save Statuses and change later so that they do not affect other cells yet
			stats.append(temp)

	var index = 0 # set new statuses
	for x in width:
		for y in height:
			grid[Vector2(x, y)].set_status(stats[index])
			index += 1
			
func get_living_neighbors(current_cell):
	var living_neighbors = 0
	for i in range(-1,2):
		for j in range(-1,2):
			var x = current_cell.get_location().x+i
			var y = current_cell.get_location().y+j
			var tempX = -1
			var tempY = -1
			
			# looking at ourselves so pass over
			if i == 0 and j == 0:
				continue
			# if we're not off the map, set X or Y for the val thats in the map
			if x >= 0 and x <= width - 1:
				tempX = x 
			if y >= 0 and y <= height - 1:
				tempY = y
			
			# off grid in X so wrap around
			if x < 0:
				tempX = width - 1
			elif x >= width:
				tempX = 0
			
			#off grid in Y so wrap around
			if y < 0:
				tempY = height - 1
			elif y >= height:
				tempY = 0
			
			living_neighbors += grid[Vector2(tempX,tempY)].get_status()
	return living_neighbors




