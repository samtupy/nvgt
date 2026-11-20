# set_endpoint
Set the node that the end of the chain sends its audio to.

`void audio_node_chain::set_endpoint(audio_node@ endpoint, uint input_bus_index = 0);`

## Arguments:
* audio_node@ endpoint: the node to send the chain's output to, or null to send it nowhere.
* uint input_bus_index = 0: the input bus of the endpoint to attach to.

## Remarks:
Attaching the chain's output bus with `attach_output_bus()` does the same.
