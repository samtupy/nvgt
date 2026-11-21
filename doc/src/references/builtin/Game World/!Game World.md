# Game World
This section contains the references for building and querying the world a game takes place in: maps of areas, pathfinding, and physics.

* coordinate_map stores a world as boxes of tiles, such as rooms, floors, walls and zones, and quickly finds the ones at any position. This suits the grid based worlds of most audio games.
* pathfinder finds the cheapest way between two tiles, asking the game how difficult each tile is to cross, which lets characters walk around obstacles.
* physics_world simulates bodies of many shapes with JoltPhysics, for worlds where things fall, collide and are pushed around, and physics_character moves a player through such a world. The physics world can also be traced with rays, such as to find what the player is facing, and given to the nvgt_phonon plugin's sound_environment so sound is occluded and reflected by it.

The two approaches can be combined, such as using a coordinate_map for what the player is standing on and a physics_world for objects that move.
