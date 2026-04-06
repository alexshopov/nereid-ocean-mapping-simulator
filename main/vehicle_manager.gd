class_name VehicleManager
extends Node

var active_vehicle : Vehicle

@onready var blue_boat : Vehicle = $BlueBoat


func _ready() -> void:
    active_vehicle = blue_boat


func get_active_vehicle_speed() -> float:
    return active_vehicle.propulsion_component.speed

func get_active_vehicle_depth() -> float:
    return active_vehicle.depth
