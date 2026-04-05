class_name PropulsionComponent
extends Node

@export var speed := 5.0

@onready var parent : Node3D = get_parent()


func _process(delta: float) -> void:
	parent.global_position.z -= speed * delta
