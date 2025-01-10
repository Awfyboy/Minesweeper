# Minesweeper

 ![Minesweeper in Godot Engine](/.media/example_screenshot.png)

 A minesweeper game made using Godot 4.3.

 This example contains a intermediate use of arrays to handle complex tasks, like storing tiles inside an array, generating tiles on the screen, determining mines and safe areas,
 finding neighbouring tiles using recursions, etc.

 Tiles are TextureButton nodes. They are treated like abstract objects holding data inside of them. When the tiles are generated, a reference to them is stored in an array.
 The program will loop within a range, instantiate tiles onto the scene and add a reference to them in the array. A SignalBus is used for determining when the user digs/flags a tile.
 It's a bit overkill to use a SignalBus, but it does help to expand projects so I thought of using it.

 Tiles are generated when a game is started by pressing one of the difficulty options or starting a custom game. However, mines are only generated AFTER the first click.
 This is done to ensure that the user won't accidentally click a mine on the first click. The game will force at least 9 tiles to be safe regardless of the amount of mines.

 One thing to note is that the system isn't perfect as there are situations where a 50/50 (guessing) can occur, so do keep that in mind.

 Left-click to dig, right-click to flag.