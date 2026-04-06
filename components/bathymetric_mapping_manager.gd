class_name BathymetricMappingManager
extends Node

signal coverage_updated(percent: float)

@export var seafloor: Seafloor
@export var texture_resolution: int = 512
@export var depth_min: float = 0.0
@export var depth_max: float = 200.0

var map_texture: ImageTexture

var _map_image: Image
var _painted: int = 0
var _dirty: bool = false
var _survey_size: float


func _ready() -> void:
	_survey_size = seafloor.size if seafloor else 1024.0
	_map_image = Image.create(texture_resolution, texture_resolution, false, Image.FORMAT_RGB8)
	map_texture = ImageTexture.create_from_image(_map_image)


func _process(_delta: float) -> void:
	if _dirty:
		map_texture.update(_map_image)
		_dirty = false
		coverage_updated.emit(get_coverage_percent())


func on_sonar_return(ping: PingData) -> void:
	var uv := _world_to_uv(ping.world_pos)
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		return

	var px := clampi(int(uv.x * texture_resolution), 0, texture_resolution - 1)
	var py := clampi(int(uv.y * texture_resolution), 0, texture_resolution - 1)
	if _map_image.get_pixel(px, py) == Color.BLACK:
		_painted += 1

	_map_image.set_pixel(px, py, _depth_color(ping.depth))

	_dirty = true


func get_coverage_percent() -> float:
	return float(_painted) / float(texture_resolution * texture_resolution) * 100.0


func _world_to_uv(p: Vector3) -> Vector2:
	return Vector2(
		(p.x + _survey_size * 0.5) / _survey_size,
		(p.z + _survey_size * 0.5) / _survey_size
	)


func _depth_color(depth: float) -> Color:
	var t := clampf((depth - depth_min) / (depth_max - depth_min), 0.0, 1.0)
	if t < 0.5:
		# dark navy → mid blue-green
		return Color(0.0, t * 0.6, 0.35 + t * 0.5)
	else:
		# mid blue-green → sandy yellow
		var s := (t - 0.5) * 2.0
		return Color(s * 0.78, 0.3 + s * 0.42, 0.6 - s * 0.37)
