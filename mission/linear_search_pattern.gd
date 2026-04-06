class_name LinearSearchPattern

static func generate(
	bounds: Rect2,
	track_spacing: float,
	start_pos: Vector3,
	heading_deg: float = 0.0
) -> Array[Vector3]:
	var waypoints: Array[Vector3] = [start_pos]
	var track_count := int(bounds.size.x / track_spacing)
	var z_near := bounds.position.y
	var z_far  := bounds.position.y + bounds.size.y

	# Find the column index closest to start_pos.x to minimise initial travel
	var nearest := clampi(
		roundi((start_pos.x - bounds.position.x) / track_spacing),
		0, track_count
	)

	# Walk right from nearest, then left — every track gets visited exactly once
	var order: Array[int] = []
	for i in range(nearest, track_count + 1):
		order.append(i)
	for i in range(nearest - 1, -1, -1):
		order.append(i)

	for idx in range(order.size()):
		var x := bounds.position.x + order[idx] * track_spacing

		if idx % 2 == 0:
			waypoints.append(Vector3(x, start_pos.y, z_near))
			waypoints.append(Vector3(x, start_pos.y, z_far))
		else:
			waypoints.append(Vector3(x, start_pos.y, z_far))
			waypoints.append(Vector3(x, start_pos.y, z_near))

	if heading_deg != 0.0:
		var center := Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
		var rot := Basis(Vector3.UP, deg_to_rad(heading_deg))
		for i in range(1, waypoints.size()):  # leave waypoints[0] (start_pos) untouched
			waypoints[i] = center + rot * (waypoints[i] - center)

	return waypoints
