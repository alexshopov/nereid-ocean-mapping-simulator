@tool
class_name SeafloorGenerator
extends Node

# WORK IN PROGRESS, NOT CURRENTLY ACTIVE


@export var rand_seed: int = 42
@export var texture_resolution: int = 512
@export var height_scale: float = 8.0

var height_image: Image


func generate(target_mesh: MeshInstance3D) -> void:
	height_image = _build_height_image()
	var tex := ImageTexture.create_from_image(height_image)
	var mat := target_mesh.get_active_material(0) as ShaderMaterial
	mat.set_shader_parameter("noise_tex", tex)
	mat.set_shader_parameter("height_scale", height_scale)


func get_height_at_uv(uv: Vector2) -> float:
	if not height_image:
		return 0.0
	var px := clampi(int(uv.x * texture_resolution), 0, texture_resolution - 1)
	var py := clampi(int(uv.y * texture_resolution), 0, texture_resolution - 1)
	return height_image.get_pixel(px, py).r * height_scale


func _build_height_image() -> Image:
	var img := Image.create(texture_resolution, texture_resolution, false, Image.FORMAT_L8)
	var base := _make_noise(rand_seed,     0.003, 3, 2.0, 0.5)  # continental shelf
	var mid  := _make_noise(rand_seed + 1, 0.015, 4, 2.0, 0.5)  # rocky ridges
	var fine := _make_noise(rand_seed + 2, 0.06,  2, 2.0, 0.5)  # fine detail
	for y in texture_resolution:
		for x in texture_resolution:
			var h: float = base.get_noise_2d(x, y) * 0.6
			h += mid.get_noise_2d(x, y) * 0.3
			h += fine.get_noise_2d(x, y) * 0.1
			h = (h + 1.0) * 0.5  # remap -1..1 → 0..1
			img.set_pixel(x, y, Color(h, h, h))
	return img


func _make_noise(s: int, freq: float, octaves: int, lacunarity: float, gain: float) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = s
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = freq
	n.fractal_type = FastNoiseLite.FRACTAL_FBM
	n.fractal_octaves = octaves
	n.fractal_lacunarity = lacunarity
	n.fractal_gain = gain
	return n
