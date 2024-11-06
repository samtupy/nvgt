# sound_pool
This class provides a convenient way of managing sounds in an environment, with 1 to 3 dimensions. The sound_pool_item class holds all the information necessary for one single sound in the game world. Note that you should not make instances of the sound_pool_item class directly but always use the methods and properties provided in the sound_pool class.

`sound_pool(int default_item_size = 100);`

## Arguments:
* int default_item_size = 100: the number of sound items to be initialized by default.