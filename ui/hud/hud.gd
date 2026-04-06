class_name HUD
extends PanelContainer

@export var vehicle_manager : VehicleManager

var active_vehicle_data : VehicleData

@onready var vehicle_id_label : Label = $%VehicleIDLabel
@onready var depth_label : Label = %DepthLabel
@onready var speed_label : Label = %SpeedLabel


func _ready() -> void:
	active_vehicle_data = vehicle_manager.active_vehicle.vehicle_data
	_update_labels()

	active_vehicle_data.changed.connect(_update_labels)


func _update_labels() -> void:
	vehicle_id_label.text = active_vehicle_data.vehicle_name
	depth_label.text = "Depth: %.1f m" % vehicle_manager.get_active_vehicle_depth()
	speed_label.text = "Speed: %.1f knots" % vehicle_manager.get_active_vehicle_speed()
