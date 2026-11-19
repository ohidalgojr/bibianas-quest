class_name PostFx
extends RefCounted
## Pós-processamento do visual (GDD §18, TASK-039): paleta reduzida por posterização, contorno por
## diferença de luminância entre vizinhos e um leve efeito de miniatura (desfoque no topo e na base).
## Aplicado como material do `SubViewportContainer`, sobre a imagem de baixa resolução.

const SHADER_CODE: String = """shader_type canvas_item;
uniform float levels = 12.0;
uniform float edge_strength = 0.6;
uniform float edge_threshold = 0.15;
uniform float blur_amount = 1.3;

float lum(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	float edge_dist = abs(UV.y - 0.5) * 2.0;
	float blur = smoothstep(0.6, 1.0, edge_dist) * blur_amount;
	vec3 c = texture(TEXTURE, UV).rgb;
	if (blur > 0.02) {
		c = (c * 2.0
			+ texture(TEXTURE, UV + vec2(px.x, 0.0) * blur).rgb
			+ texture(TEXTURE, UV - vec2(px.x, 0.0) * blur).rgb
			+ texture(TEXTURE, UV + vec2(0.0, px.y) * blur).rgb
			+ texture(TEXTURE, UV - vec2(0.0, px.y) * blur).rgb) / 6.0;
	}
	float l = lum(c);
	float e = max(
		max(abs(l - lum(texture(TEXTURE, UV + vec2(px.x, 0.0)).rgb)), abs(l - lum(texture(TEXTURE, UV - vec2(px.x, 0.0)).rgb))),
		max(abs(l - lum(texture(TEXTURE, UV + vec2(0.0, px.y)).rgb)), abs(l - lum(texture(TEXTURE, UV - vec2(0.0, px.y)).rgb))));
	float edge = smoothstep(edge_threshold, edge_threshold + 0.12, e);
	c = floor(c * levels + 0.5) / levels;
	c = mix(c, c * 0.3, edge * edge_strength);
	COLOR = vec4(c, 1.0);
}
"""

static var _shader: Shader


## Material do pós-processamento, ou null se o aparelho desligou o efeito.
static func material() -> ShaderMaterial:
	if not GfxSettings.post_fx:
		return null
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	return mat


## Liga o pós-processamento ao contêiner de uma `SubViewport` (se estiver habilitado).
static func apply(container: SubViewportContainer) -> void:
	var mat: ShaderMaterial = material()
	if mat != null:
		container.material = mat
