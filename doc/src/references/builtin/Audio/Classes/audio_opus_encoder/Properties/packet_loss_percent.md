# packet_loss_percent
The percentage of packets that are expected to be lost on the way to the listener, from 0 to 100.

`int audio_opus_encoder::packet_loss_percent;`

## Remarks:
The default is 0. Telling the encoder to expect loss makes it add information that helps the decoder hide missing packets, at the cost of some quality.
