class_name HUD
extends PanelContainer

@export var blue_boat : BlueBoat

@onready var speed_label : Label = %SpeedLabel


func _ready() -> void:
	speed_label.text = "Speed: %.1f knots" % blue_boat.propulsion_component.speed
