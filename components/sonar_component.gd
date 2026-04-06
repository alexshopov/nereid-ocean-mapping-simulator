class_name SonarComponent
extends Node3D

signal sonar_return(ping: PingData)

@export var seafloor: Seafloor
@export var ping_rate_hz: float = 2.0
@export var beam_count: int = 16
@export var swath_angle_deg: float = 120.0
@export var max_range_m: float = 200.0

const MARCH_STEP := 0.5

var scanning := true

var _time_accum: float = 0.0
var _beam_mesh: ImmediateMesh

@onready var _parent: Vehicle = get_parent()


func _ready() -> void:
	assert(is_instance_valid(_parent), "SonarComponent must be a child of a Vehicle entity")

	_beam_mesh = ImmediateMesh.new()
	var vis: MeshInstance3D = MeshInstance3D.new()
	vis.mesh = _beam_mesh

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.3, 0.3, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	vis.material_override = mat
	add_child(vis)


func _process(delta: float) -> void:
	if not scanning:
		return

	_time_accum += delta
	if _time_accum >= 1.0 / ping_rate_hz:
		_time_accum = 0.0
		_ping()


func _ping() -> void:
	if not seafloor:
		return

	var origin := global_position
	print(origin)
	var right := global_transform.basis.x
	var half_swath := deg_to_rad(swath_angle_deg * 0.5)

	_beam_mesh.clear_surfaces()
	_beam_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	for i in beam_count:
		var t := float(i) / float(beam_count - 1)
		var angle : float = lerp(-half_swath, half_swath, t)
		var dir := (right * sin(angle) + Vector3.DOWN * cos(angle)).normalized()
		var hit := _march(origin, dir)

		if hit != Vector3.INF:
			_beam_mesh.surface_add_vertex(Vector3.ZERO)
			_beam_mesh.surface_add_vertex(to_local(hit))

			sonar_return.emit(PingData.new(hit, origin.y - hit.y))

	_beam_mesh.surface_end()


func _march(origin: Vector3, direction: Vector3) -> Vector3:
	var pos := origin
	for _i in int(max_range_m / MARCH_STEP):
		pos += direction * MARCH_STEP
		if pos.y <= seafloor.get_height_at(pos.x, pos.z):
			return pos
	return Vector3.INF
