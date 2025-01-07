extends TextureButton
class_name Tile

# index of the object in the grid array
var virtual_pos: int = 0

# state of the tile based on the enum in the Game scene
var state: int = 0

# number of mines near this tile
var mines_nearby: int = 0

# used for checking whether the tile is clickable
var is_hidden: bool = true

# emit the virtual position along with the mouse button that was pressed
# ensure that the tile is hidden, otherwise it shouldn't be clickable
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_hidden:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				SignalBus.tile_pressed.emit(virtual_pos, MOUSE_BUTTON_LEFT)
			MOUSE_BUTTON_RIGHT:
				SignalBus.tile_pressed.emit(virtual_pos, MOUSE_BUTTON_RIGHT)
