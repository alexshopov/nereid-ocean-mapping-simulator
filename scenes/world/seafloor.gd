@tool
class_name Seafloor
extends MeshInstance3D

@export var size := 1024.0 :
	set(new_size):
		size = new_size
		_update_mesh()

@export_range(4, 256, 4) var resolution := 32 :
	set(new_resolution):
		resolution = new_resolution
		_update_mesh()

@export var noise : FastNoiseLite :
	set(new_noise):
		noise = new_noise
		_update_mesh()
		if noise:
			noise.changed.connect(_update_mesh)

@export_range(4.0, 128.0, 4.0) var height := 64 :
	set(new_height):
		height = new_height
		var mat := get_surface_override_material(0)
		mat.set_shader_parameter("height", height * 2)
		set_surface_override_material(0, mat)
		_update_mesh()


func _get_height(x: float, y: float) -> float:
	return noise.get_noise_2d(x, y) * height


func _get_normal(x: float, y: float) -> Vector3:
	var epsilon := size / resolution
	var normal := Vector3(
		(_get_height(x + epsilon, y) - _get_height(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(_get_height(x, y + epsilon) - _get_height(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()


func _update_mesh() -> void:
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)

	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array= plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array= plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tanget_array: PackedFloat32Array= plane_arrays[ArrayMesh.ARRAY_TANGENT]

	for i: int in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tanget := Vector3.RIGHT

		if noise:
			vertex.y = _get_height(vertex.x, vertex.z)
			normal = _get_normal(vertex.x, vertex.z)
			tanget = normal.cross(Vector3.UP)

		vertex_array[i] = vertex
		normal_array[i] = normal
		tanget_array[4 * i] = tanget.x
		tanget_array[4 * i + 1] = tanget.y
		tanget_array[4 * i + 2] = tanget.z

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh
