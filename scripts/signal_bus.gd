extends Node

# I'm aware that it's overkill to use an autoload for this, but it helps to decouple your code
# especially if you want to expand the project further
# SignalBuses are just more convenient in that regard
signal tile_pressed(virtual_pos: int, mouse_button: int)
