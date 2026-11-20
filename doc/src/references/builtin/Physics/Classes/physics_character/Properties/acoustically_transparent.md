# acoustically_transparent
Whether sound passes through the character's body without being blocked.

`bool physics_character::acoustically_transparent;`

## Remarks:
This is true by default. The player's listener and the sounds that characters make are inside their bodies, so if the characters blocked acoustic rays, every sound would be muffled by the person making it. Set it to false if you want a character to block sound, for example a large monster.
