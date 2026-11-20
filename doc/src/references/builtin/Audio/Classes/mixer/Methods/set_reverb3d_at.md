# set_reverb3d_at
Send the mixer to a reverb3d, choosing which point of its spatialization the send is taken from.

`void mixer::set_reverb3d_at(reverb3d@ reverb, reverb3d_placement placement);`

## Arguments:
* reverb3d@ reverb: the reverb to send the mixer to, or null to stop sending it to one.
* reverb3d_placement placement: where the send is taken from, see the reverb3d_placement enum.

## Remarks:
Setting the `reverb3d` property does the same with reverb3d_postpan, which suits most uses.
