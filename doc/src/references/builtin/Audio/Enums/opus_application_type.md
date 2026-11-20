# opus_application_type
This is a list of the uses that an audio_opus_encoder can be set up for, used with its `application` property.

* OPUS_APPLICATION_VOIP: voice chat, favoring the clarity of speech.
* OPUS_APPLICATION_AUDIO: music and general audio, favoring faithfulness to the input. This is the default.
* OPUS_APPLICATION_RESTRICTED_LOWDELAY: the lowest possible delay, at some cost to quality.
