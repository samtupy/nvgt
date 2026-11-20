# audio_encoder_flags
This is a list of flags for `audio_encoder::open()` that every encoder accepts.

* AUDIO_ENCODER_OVERWRITE: replace the file if it already exists.
* AUDIO_ENCODER_DEFAULTS: the encoder's `default_open_flags`, which include AUDIO_ENCODER_OVERWRITE.

Combine these with the flags of a particular encoder using the bitwise or operator.
