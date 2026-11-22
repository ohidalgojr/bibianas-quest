class_name PostFx
extends RefCounted
## Pós-processamento do visual (GDD §18, TASK-039): paleta reduzida por posterização, contorno por
## diferença de luminância entre vizinhos e um leve efeito de miniatura (desfoque no topo e na base).
## Aplicado como material do `SubViewportContainer`, sobre a imagem de baixa resolução.

const SHADER_CODE: String = """shader_type canvas_item;
uniform float levels = 16.0;
uniform float edge_strength = 0.6;
uniform float edge_threshold = 0.15;
uniform float blur_amount = 1.3;
uniform float dither_strength = 0.9;
uniform vec3 shadow_tone = vec3(0.82, 0.92, 1.12);
uniform vec3 light_tone = vec3(1.08, 1.0, 0.88);

// Matriz de Bayer 4x4 (dithering de PS1, D-ART-2).
float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = x + y * 4;
	float m[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
	return m[i] / 16.0 - 0.5;
}

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
	// Split-toning de mundo morrendo: sombras azul-ardósia, luzes quentes e sujas.
	c *= mix(shadow_tone, light_tone, smoothstep(0.1, 0.7, l));
	vec2 grid = floor(UV / TEXTURE_PIXEL_SIZE);
	c += bayer4(grid) * dither_strength / levels;
	c = floor(c * levels + 0.5) / levels;
	c = mix(c, c * 0.3, edge * edge_strength);
	COLOR = vec4(c, 1.0);
}
"""

## Desfoque do combate (D-ART-2): o inimigo precisa ficar nítido (era 1,3).
const COMBAT_BLUR: float = 0.35

static var _shader: Shader


## Material do pós-processamento, ou null se o aparelho desligou o efeito.
static func material(blur: float = 1.3) -> ShaderMaterial:
	if not GfxSettings.post_fx:
		return null
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("blur_amount", blur)
	return mat


## Liga o pós-processamento ao contêiner de uma `SubViewport` (se estiver habilitado).
static func apply(container: SubViewportContainer, blur: float = 1.3) -> void:
	var mat: ShaderMaterial = material(blur)
	if mat != null:
		container.material = mat
