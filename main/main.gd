@tool
class_name Sim
extends Node

@onready var seafloor: Seafloor = $World/Seafloor
@onready var blue_boat: Node3D = $VehicleManager/BlueBoat
@onready var map_marker: MeshInstance3D = %MapMarker
@onready var camera: Camera3D = $VehicleManager/BlueBoat/Camera3D
@onready var bathy_mapping_manager: BathymetricMappingManager = $BathymetricMappingManager
@onready var seed_label: Label = %SeedLabel
@onready var navigation_component: NavigationComponent = $VehicleManager/BlueBoat/NavigationComponent


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var sonar := blue_boat.get_node("SonarComponent") as SonarComponent
	sonar.seafloor = seafloor
	sonar.sonar_return.connect(bathy_mapping_manager.on_sonar_return)

	seed_label.text = "Seed: %d" % seafloor.noise.seed

	blue_boat.global_position = navigation_component.get_start_position(seafloor)
	navigation_component.init(seafloor)
	navigation_component.start()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("zoom_in"):  camera.fov -= 1.0
		if Input.is_action_just_pressed("zoom_out"): camera.fov += 1.0

		if Input.is_action_just_pressed("view_birdeye"):
			_on_birds_eye_camera_button_pressed()

		if Input.is_action_just_pressed("view_active_vehicle"):
			_on_chase_camera_button_pressed()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_chase_camera_button_pressed() -> void:
	camera.top_level = false
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.position = Vector3(0, 10, 10)
	camera.rotation_degrees = Vector3(-35, 0, 0)
	map_marker.hide()


func _on_birds_eye_camera_button_pressed() -> void:
	camera.top_level = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2000.0
	camera.global_position = Vector3(-150, 750, -25)
	camera.rotation_degrees = Vector3(-90, 0, 0)
	map_marker.show()
