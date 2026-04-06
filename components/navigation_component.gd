class_name NavigationComponent
extends Node

signal waypoints_complete

const TRACK_SPACING := 300.0
const SURVEY_INSET := 20.0

@export var propulsion_component: PropulsionComponent
@export var sonar_component: SonarComponent
@export var waypoint_arrival_distance := 3.0

var waypoints: Array[Vector3] = []
var current_waypoint_idx := 0
var _active := false

@onready var _parent: Node3D = get_parent()


func _ready() -> void:
	if sonar_component == null:
		sonar_component = _parent.get_node_or_null("SonarComponent")


func get_start_position(seafloor: Seafloor) -> Vector3:
	var b := _get_bounds(seafloor)
	return Vector3(b.position.x, _parent.global_position.y, b.position.y)


func init(seafloor: Seafloor) -> void:
	waypoints = LinearSearchPattern.generate(
		_get_bounds(seafloor), TRACK_SPACING, _parent.global_position
	)


func _get_bounds(seafloor: Seafloor) -> Rect2:
	var half := seafloor.size * 0.5
	var inset := SURVEY_INSET
	return Rect2(
		seafloor.global_position.x - half + inset,
		seafloor.global_position.z - half + inset,
		seafloor.size - inset * 2.0,
		seafloor.size - inset * 2.0
	)


func start() -> void:
	current_waypoint_idx = 0
	_active = true


func _process(_delta: float) -> void:
	if not _active:
		return

	if current_waypoint_idx >= waypoints.size():
		propulsion_component.velocity = Vector3.ZERO
		_active = false
		waypoints_complete.emit()
		return

	var target := waypoints[current_waypoint_idx]
	var to_target := Vector3(
		target.x - _parent.global_position.x,
		0.0,
		target.z - _parent.global_position.z
	)

	if to_target.length() < waypoint_arrival_distance:
		current_waypoint_idx += 1
		return

	var dir := to_target.normalized()
	propulsion_component.velocity = dir * propulsion_component.speed
	_parent.look_at(_parent.global_position + dir, Vector3.UP)
	if sonar_component:
		sonar_component.scanning = absf(dir.z) >= absf(dir.x)
