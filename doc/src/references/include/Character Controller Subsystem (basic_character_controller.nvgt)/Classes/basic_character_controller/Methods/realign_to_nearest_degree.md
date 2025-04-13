# `realign_to_nearest_degree`

Instructs the controller that it should reorient itself such that it is facing the closest valid compass point to it's current yaw.

```nvgt
void realign_to_nearest_degree(const float step=2.8125) final;
```

## Parameters

* `const float step`: Used for snapping degrees to the nearest compass point, this parameter allows you to change the granularity of snapping behaviors.

