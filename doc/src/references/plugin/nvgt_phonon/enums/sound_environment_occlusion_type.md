# sound_environment_occlusion_type
This is a list of the ways a sound_environment_source can determine how occluded it is, set with `sound_environment_source::occlusion_type`.

* SOUND_ENVIRONMENT_OCCLUSION_RAYCAST: a single ray is traced between the sound and the listener, so a sound is either occluded or not. This is the cheapest type, and ignores `occlusion_radius` and `occlusion_samples`.
* SOUND_ENVIRONMENT_OCCLUSION_VOLUMETRIC: the sound is treated as a sphere with the source's `occlusion_radius`, and the fraction of `occlusion_samples` points on it that the listener can see gives the occlusion. Sounds fade in and out gradually as they pass the edge of an obstacle, which is smoother and more realistic.
