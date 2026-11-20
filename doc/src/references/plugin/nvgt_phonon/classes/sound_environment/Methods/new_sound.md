# new_sound
Create a new sound that is already attached to this environment.

`sound@ sound_environment::new_sound();`

## Returns:
sound@: the new sound, or null if it could not be created.

## Remarks:
This is equivalent to creating a sound from the environment's engine and passing it to `attach()`. Every attached sound or mixer is simulated separately though nvgt does try to reduce processing when many sounds near each other play even without a mixer, so for an object that makes several sounds it is cheaper to create one mixer with `new_mixer()` and play the sounds through that.
