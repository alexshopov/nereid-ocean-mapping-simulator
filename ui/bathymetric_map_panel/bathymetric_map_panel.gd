class_name BathymetricMapPanel
extends PanelContainer

@export var bathy_mapping_manager: BathymetricMappingManager

@onready var map : TextureRect = $Map


func _ready() -> void:
	map.texture = bathy_mapping_manager.map_texture
