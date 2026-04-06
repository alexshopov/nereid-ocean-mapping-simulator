class_name Vehicle
extends Node3D

@export var vehicle_data : VehicleData

var depth := 0.0

@onready var propulsion_component : PropulsionComponent = $PropulsionComponent
@onready var sonar_component : SonarComponent = $SonarComponent
