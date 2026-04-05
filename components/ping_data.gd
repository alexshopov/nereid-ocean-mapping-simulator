class_name PingData
extends RefCounted

var world_pos: Vector3
var depth: float


func _init(pos: Vector3, d: float) -> void:
	world_pos = pos
	depth = d
