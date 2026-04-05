@tool
class_name Sim
extends Node

@onready var seafloor: Seafloor = $Seafloor
@onready var camera : Camera3D = $Camera3D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in"):	 camera.fov -= 1.0
	if Input.is_action_just_pressed("zoom_out"): camera.fov += 1.0



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
