### MINESWEEPER Godot 4.3 example - by Awf Ibrahim (@awfyboy)
extends Node

# states for the tiles
enum states {SAFE, CAUTION, MINE}

# texture resources
const CAUTION_1 = preload("res://sprites/1.png")
const CAUTION_2 = preload("res://sprites/2.png")
const CAUTION_3 = preload("res://sprites/3.png")
const CAUTION_4 = preload("res://sprites/4.png")
const CAUTION_5 = preload("res://sprites/5.png")
const CAUTION_6 = preload("res://sprites/6.png")
const CAUTION_7 = preload("res://sprites/7.png")
const CAUTION_8 = preload("res://sprites/8.png")
const MINE = preload("res://sprites/mine.png")
const MINE_SELECTED = preload("res://sprites/mine_selected.png")
const FLAG = preload("res://sprites/flag.png")
const HIDDEN = preload("res://sprites/hidden.png")
const SAFE = preload("res://sprites/safe.png")

# game related values
const TILE = preload("res://scenes/tile.tscn")
const GRID_SIZE: int = 32

var test_rows: int = 5
var test_columns: int = 8

# I'm using a 1D array (which is harder honestly) but you may adapt this to a 2D array
var grid: Array[Tile] = []


# return the size of the viewport
func get_viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size


# add a tile scene onto the given position and set a virtual position
# store their references as elements of the grid
func add_tile(pos: Vector2, virtual_pos: int) -> void:
	## create new instance of a tile and add it to the root node
	var tile_instance: Tile = TILE.instantiate()
	add_child(tile_instance)
	
	## set its position, virtual position, and texture 
	tile_instance.position = pos
	tile_instance.virtual_pos = virtual_pos
	tile_instance.texture_normal = HIDDEN
	
	## store its reference as an element of the grid
	grid.append(tile_instance)


# clear the grid
func reset_grid() -> void:
	## ensure that the grid isn't already empty before clearing
	if grid.size() > 0:
		for i in range(grid.size()):
			var tile: Tile = grid[i]
			tile.queue_free()
		grid.clear()


# create tiles inside of the grid
func generate_tiles(rows: int, columns: int, mines: int) -> void:
	## first, reset any existing grid
	reset_grid()
	
	## add tiles to the root node and grid
	## the tile scenes are treated like abstract objects
	## they will have 'virtual positions' based on the grid
	## these positions are simply their index position on the grid array
	## columns for x-axis and rows for y-axis
	for y in range(rows):
		for x in range(columns):
			## calculate offsets for tile position
			var grid_width: int = GRID_SIZE * columns
			var grid_height: int = GRID_SIZE * rows
			var screen_width: int = get_viewport_size().x
			var screen_height: int = get_viewport_size().y
			var hor_offset: int = ((screen_width - grid_width)/2)
			var ver_offset: int = ((screen_height - grid_height)/2)
			
			## add new tile and set its position and virtual position
			var tile_pos: Vector2 = Vector2((GRID_SIZE * x) + hor_offset, (GRID_SIZE * y) + ver_offset)
			var virtual_pos: int = x + (y * columns)
			add_tile(tile_pos, virtual_pos)
	
	## randomly select some tiles to be mines
	## ensure that no tile can be selected more than once
	## this is done by creating a copy of the grid, shuffling it, then getting elements from the back
	var grid_copy = grid.duplicate(true)
	grid_copy.shuffle()
	
	## prevent mine count from being greater than the number of tiles or less than 0
	var mine_count: int = clamp(mines, 0, (rows * columns))
	
	## assign some tiles as mines
	for i in range(mine_count):
		var tile: Tile = grid_copy.pop_back()
		tile.state = states.MINE
	
	## update grid to have caution tiles
	## tiles with mines next to them should be a caution tile
	## update 'mine_nearby' for each mine next to the tile
	for y in range(rows):
		for x in range(columns):
			## get current tile of this loop
			var tile: Tile = grid[x + (y * columns)]
			
			## if this tile is a mine, ignore it and immediately skip to the next iteration
			if tile.state == states.MINE:
				continue
			
			## get the tiles nearby this tile
			var nearby_tiles: Array[Tile] = get_nearby_tiles(y, x, rows, columns)
			
			## if a nearby tile is a mine, increment 'mines_nearby' and set state to caution
			for nearby_tile in nearby_tiles:
				if nearby_tile.state == states.MINE:
					tile.state = states.CAUTION
					tile.mines_nearby += 1


# get the nearby tiles from the given tile
# use current row and current column of the given tile to find the nearby tiles
func get_nearby_tiles(row: int, column: int, total_rows: int, total_columns: int) -> Array[Tile]:
	#var tile: Tile = grid[tile_index]
	## append nearby tiles' index to this array
	var nearby_tiles: Array[Tile] = []
	
	## all possible nearby tiles, including out-of-bounds tiles
	var top_left: int = (column - 1) + ((row - 1) * total_columns)
	var top: int = column + ((row - 1) * total_columns)
	var top_right: int = (column + 1) + ((row - 1) * total_columns)
	var left: int = (column - 1) + (row * total_columns)
	var right: int = (column + 1) + (row * total_columns)
	var bottom_left: int = (column - 1) + ((row + 1) * total_columns)
	var bottom: int = column + ((row + 1) * total_columns)
	var bottom_right: int = (column + 1) + ((row + 1) * total_columns)
	
	## the first and last tiles of each nearby row
	var left_bound: int = row * total_columns
	var right_bound: int = (row * total_columns) + total_columns - 1
	var top_left_bound: int = (row - 1) * total_columns
	var top_right_bound: int = ((row - 1) * total_columns) + total_columns - 1
	var bottom_left_bound: int = (row + 1) * total_columns
	var bottom_right_bound: int = ((row + 1) * total_columns) + total_columns - 1
	
	## append tiles that are within bounds of the grid
	if top_left >= 0 and top_left >= top_left_bound:
		nearby_tiles.append(grid[top_left])
	if top >= 0:
		nearby_tiles.append(grid[top])
	if top_right >= 0 and top_right <= top_right_bound:
		nearby_tiles.append(grid[top_right])
	if left >= 0 and left >= left_bound:
		nearby_tiles.append(grid[left])
	if right < (total_rows * total_columns) and right <= right_bound:
		nearby_tiles.append(grid[right])
	if bottom_left < (total_rows * total_columns) and bottom_left >= bottom_left_bound:
		nearby_tiles.append(grid[bottom_left])
	if bottom < (total_rows * total_columns):
		nearby_tiles.append(grid[bottom])
	if bottom_right < (total_rows * total_columns) and bottom_right <= bottom_right_bound:
		nearby_tiles.append(grid[bottom_right])
	
	## return the list of possible nearby tiles
	return nearby_tiles


# reveal the tile selected from the grid
func reveal_tile(tile: Tile) -> void:
	## after reveal, the tile shouldn't be clickable
	tile.is_hidden = false
	
	## update texture based on its state
	match tile.state:
		states.SAFE:
			tile.texture_normal = SAFE
		states.MINE:
			tile.texture_normal = MINE_SELECTED
		states.CAUTION:
			## if this is a caution tile, check the number of bombs nearby
			## you can probably just check the integer and get the texture using a string
			## I did it this way since I preload my textures anyways
			match tile.mines_nearby:
				1:
					tile.texture_normal = CAUTION_1
				2:
					tile.texture_normal = CAUTION_2
				3:
					tile.texture_normal = CAUTION_3
				4:
					tile.texture_normal = CAUTION_4
				5:
					tile.texture_normal = CAUTION_5
				6:
					tile.texture_normal = CAUTION_6
				7:
					tile.texture_normal = CAUTION_7
				8:
					tile.texture_normal = CAUTION_8


# reveal all the mines in the grid
func reveal_mines() -> void:
	for tile in grid:
		if tile.state == states.MINE:
			tile.texture_normal = MINE
			tile.is_hidden = false


# DEBUG: reveal all tiles on the grid
func reveal_all_tiles() -> void:
	for tile in grid:
		reveal_tile(tile)


# initialize new game at the start of program
func _ready() -> void:
	## connect to signals from the SignalBus
	SignalBus.tile_pressed.connect(on_tile_pressed)
	
	## start a new game
	generate_tiles(20, 16, 40)
	reveal_all_tiles()


# call when a tile is pressed
func on_tile_pressed(virtual_pos: int, mouse_button: int) -> void:
	var tile: Tile = grid[virtual_pos]
	tile.queue_free()


func _on_button_pressed() -> void:
	generate_tiles(20, 16, 40)
	reveal_all_tiles()
