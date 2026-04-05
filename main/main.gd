@tool
class_name Sim
extends Node

@onready var seafloor: Seafloor = $Seafloor
@onready var camera: Camera3D = $BlueBoat/Camera3D
@onready var blue_boat: Node3D = $BlueBoat
@onready var bathy_map: BathymetricMapDisplay = $BathymetricMapDisplay
@onready var minimap : TextureRect = %MiniMap


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var sonar := blue_boat.get_node("SonarComponent") as SonarComponent
	sonar.seafloor = seafloor
	sonar.sonar_return.connect(bathy_map.on_sonar_return)

	minimap.texture = bathy_map.map_texture



func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("zoom_in"):  camera.fov -= 1.0
		if Input.is_action_just_pressed("zoom_out"): camera.fov += 1.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
