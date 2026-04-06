class_name PropulsionComponent
extends Node

@export var speed := 5.0

var velocity := Vector3.ZERO

@onready var parent: Node3D = get_parent()


func _process(delta: float) -> void:
	parent.global_position += velocity * delta
