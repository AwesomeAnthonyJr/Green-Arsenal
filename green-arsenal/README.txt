Green Arsenal Project Structure Breakdown

***EXPLAINING MAIN***:
There's a node called "main" which is the scene root,
meaning the engine automatically runs main when you press play.

Currently it looks like this:
	o Main
	|-o Testing
	|-o InputManager

This will matter more for the future but here's the idea:
	1.  Anything under "testing" will not be interfered by
		main once it handles loading things (which it will eventually)
	2.  For something like the player (or something that reads inputs)
		to work, it needs to be a descendant of main somehow.
		2b. If you want to make something that reads the games inputs,
			use the player's "connect_inputs" function as a sort of guide.
	3.  For the whole system to work, main's export attributes must be
		set, I think they will be, but i have no idea how github will
		handle them.

Basically throw whatever you want under testing, remove whatever you want
under testing and it should be all fine for the merge.

***MISC OTHER STUFF***:
	- The camera detects collisions only from colliders on collision
	  layer 2; when adding like level geometry make sure has that layer.
	- When using the cel shader, make sure you have a world environment
	  node with ambient lighting set to "disabled", or colors will be
	  sort of washed out. Also make sure you have a directional light
	  in the scene at all or it gets weird. If you don't want any light
	  still add one and set the energy to zero.
	- Try to keep things organized into their respective folders
	- Use "_physics_process" rather than "_process" if you are doing
	  physics calculations / movement / other stuff, to put it simply
	  _process uses the computers fastest framerate possible which
	  also means inconsistent between frames, while _physics_process
	  really tries to be regularly scheduled and also runs on a seperate
	  thread optimized for physics if i remember correctly.
