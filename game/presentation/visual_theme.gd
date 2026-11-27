class_name VisualTheme
extends RefCounted
## Direção visual Dark Fantasy e regra do acento (GDD §3, §17, §18, §19, TASK-031, ADR-0035;
## mecha colorida removida em F-024), retratos vetoriais (Bibiana + 7 inimigos), brasões do tabuleiro
## e medalhão visual da moeda com símbolos distintos para Cara e Coroa.

const COLOR_BG_DEEP: Color = Color(0.05, 0.055, 0.075, 1.0)
const COLOR_STONE_DARK: Color = Color(0.10, 0.11, 0.14, 1.0)
const COLOR_STONE_MID: Color = Color(0.17, 0.18, 0.22, 1.0)
const COLOR_BORDER_BRONZE: Color = Color(0.42, 0.35, 0.24, 1.0)
const COLOR_GOLD: Color = Color(0.92, 0.75, 0.26, 1.0)
const COLOR_DANGER: Color = Color(0.86, 0.22, 0.20, 1.0)
const COLOR_PARCHMENT: Color = Color(0.88, 0.85, 0.78, 1.0)

## Realce do nó atual no tabuleiro (bronze claro; sem relação com cor de cabelo, F-024).
const COLOR_CURRENT_NODE: Color = Color(0.80, 0.68, 0.42, 1.0)


static func styled_panel(bg: Color = COLOR_STONE_DARK, border: Color = COLOR_BORDER_BRONZE, radius: int = 8) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(12)
	return style


## Desenha um brasão vetorial para cada tipo de nó do mapa (GDD §5, §17, §19).
static func draw_node_emblem(canvas: CanvasItem, center: Vector2, kind: int, radius: float, tint: Color) -> void:
	match kind:
		MapNode.Kind.START:
			# Estandarte / portal de entrada
			canvas.draw_circle(center, radius * 0.55, tint)
			canvas.draw_arc(center, radius * 0.8, 0.0, TAU, 20, COLOR_PARCHMENT, 2.0)
		MapNode.Kind.BATTLE:
			# Duas espadas cruzadas
			var d: float = radius * 0.65
			canvas.draw_line(center + Vector2(-d, -d), center + Vector2(d, d), tint, 2.5)
			canvas.draw_line(center + Vector2(-d, d), center + Vector2(d, -d), tint, 2.5)
		MapNode.Kind.AMBUSH:
			# Dois olhos oblíquos espreitando na sombra
			canvas.draw_circle(center + Vector2(-radius * 0.38, 0), radius * 0.24, COLOR_DANGER)
			canvas.draw_circle(center + Vector2(radius * 0.38, 0), radius * 0.24, COLOR_DANGER)
		MapNode.Kind.ELITE:
			# Crânio com chifres
			canvas.draw_circle(center, radius * 0.48, tint)
			canvas.draw_line(center + Vector2(-radius * 0.3, -radius * 0.2), center + Vector2(-radius * 0.85, -radius * 0.75), COLOR_DANGER, 2.5)
			canvas.draw_line(center + Vector2(radius * 0.3, -radius * 0.2), center + Vector2(radius * 0.85, -radius * 0.75), COLOR_DANGER, 2.5)
		MapNode.Kind.CHEST:
			# Baú ferrado com fecho dourado
			var rect: Rect2 = Rect2(center - Vector2(radius * 0.65, radius * 0.45), Vector2(radius * 1.3, radius * 0.9))
			canvas.draw_rect(rect, tint, true)
			canvas.draw_rect(rect, COLOR_GOLD, false, 2.0)
			canvas.draw_circle(center, radius * 0.16, COLOR_GOLD)
		MapNode.Kind.EVENT:
			# Obelisco / losango de mistério
			var pts: PackedVector2Array = PackedVector2Array([
				center + Vector2(0, -radius * 0.75),
				center + Vector2(radius * 0.6, 0),
				center + Vector2(0, radius * 0.75),
				center + Vector2(-radius * 0.6, 0),
			])
			canvas.draw_colored_polygon(pts, tint)
		MapNode.Kind.BONFIRE:
			# Chama de fogueira
			var flame: PackedVector2Array = PackedVector2Array([
				center + Vector2(0, -radius * 0.82),
				center + Vector2(radius * 0.55, radius * 0.35),
				center + Vector2(0, radius * 0.65),
				center + Vector2(-radius * 0.55, radius * 0.35),
			])
			canvas.draw_colored_polygon(flame, Color(0.95, 0.52, 0.16))
			canvas.draw_circle(center + Vector2(0, radius * 0.15), radius * 0.26, COLOR_GOLD)
		MapNode.Kind.MINI_BOSS:
			# Sino rachado
			var bell: PackedVector2Array = PackedVector2Array([
				center + Vector2(-radius * 0.35, -radius * 0.65),
				center + Vector2(radius * 0.35, -radius * 0.65),
				center + Vector2(radius * 0.7, radius * 0.45),
				center + Vector2(-radius * 0.7, radius * 0.45),
			])
			canvas.draw_colored_polygon(bell, COLOR_GOLD.darkened(0.15))
			canvas.draw_line(center + Vector2(0, -radius * 0.2), center + Vector2(radius * 0.2, radius * 0.45), COLOR_DANGER, 2.2)
		MapNode.Kind.BOSS:
			# Lápide / portão do Coveiro com cruz
			var gate: Rect2 = Rect2(center - Vector2(radius * 0.55, radius * 0.65), Vector2(radius * 1.1, radius * 1.3))
			canvas.draw_rect(gate, COLOR_DANGER.darkened(0.25), true)
			canvas.draw_rect(gate, COLOR_GOLD, false, 2.0)
			canvas.draw_line(center + Vector2(0, -radius * 0.45), center + Vector2(0, radius * 0.45), COLOR_GOLD, 2.5)
			canvas.draw_line(center + Vector2(-radius * 0.32, -radius * 0.15), center + Vector2(radius * 0.32, -radius * 0.15), COLOR_GOLD, 2.5)


## Retrato vetorial 2D para a Bibiana (cabelo castanho-escuro natural, F-024) e para os 7 inimigos
## (GDD §9, §18). Herda de ColorRect para manter compatibilidade total com CombatScreen.
class PortraitCanvas extends ColorRect:
	var subject_id: String = "bibiana"
	var power_level: float = 1.0
	var mutation_id: String = ""

	func configure_player(power: float) -> void:
		subject_id = "bibiana"
		power_level = power
		mutation_id = ""
		queue_redraw()

	func configure_enemy(enemy_id: String, mutation: String = "") -> void:
		subject_id = enemy_id
		mutation_id = mutation
		queue_redraw()

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		if w <= 4.0 or h <= 4.0:
			return
		var c: Vector2 = Vector2(w * 0.5, h * 0.5)
		# Moldura de arco gótico da Cidade Abandonada
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.085, 0.11, 1.0), true)
		draw_arc(Vector2(c.x, h * 0.42), minf(w, h) * 0.40, PI, TAU, 20, Color(0.20, 0.21, 0.27, 0.9), 2.0)
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), VisualTheme.COLOR_BORDER_BRONZE, false, 2.0)

		if not mutation_id.is_empty():
			_draw_mutation_aura(c, minf(w, h) * 0.42)

		if subject_id == "bibiana":
			_draw_bibiana(c, minf(w, h))
		else:
			_draw_enemy(subject_id, c, minf(w, h))

	func _draw_bibiana(c: Vector2, s: float) -> void:
		# Manto e ombros de malha
		var torso: PackedVector2Array = PackedVector2Array([
			c + Vector2(-s * 0.28, s * 0.38),
			c + Vector2(-s * 0.20, -s * 0.04),
			c + Vector2(s * 0.20, -s * 0.04),
			c + Vector2(s * 0.28, s * 0.38),
		])
		draw_colored_polygon(torso, Color(0.24, 0.27, 0.34))
		# Cabeça e capuz
		draw_circle(c + Vector2(0, -s * 0.17), s * 0.14, Color(0.76, 0.70, 0.64))
		# Cabelo curto castanho-escuro natural (F-024)
		draw_circle(c + Vector2(-s * 0.02, -s * 0.25), s * 0.10, Color(0.20, 0.14, 0.11))
		# Escudo na esquerda
		var shield_rect: Rect2 = Rect2(c + Vector2(-s * 0.34, -s * 0.02), Vector2(s * 0.22, s * 0.30))
		draw_rect(shield_rect, Color(0.32, 0.35, 0.42), true)
		draw_rect(shield_rect, VisualTheme.COLOR_BORDER_BRONZE, false, 2.0)
		# Espada erguida na direita
		draw_line(c + Vector2(s * 0.24, s * 0.20), c + Vector2(s * 0.34, -s * 0.28), Color(0.84, 0.86, 0.90), 3.0)
		draw_line(c + Vector2(s * 0.17, s * 0.04), c + Vector2(s * 0.33, s * 0.08), VisualTheme.COLOR_GOLD, 2.5)

	func _draw_enemy(enemy_id: String, c: Vector2, s: float) -> void:
		match enemy_id:
			"infected_citizen":
				# Silhueta curvada com manto esfarrapado e pústula esverdeada
				var body: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.25, s * 0.38),
					c + Vector2(-s * 0.18, -s * 0.10),
					c + Vector2(s * 0.15, -s * 0.06),
					c + Vector2(s * 0.24, s * 0.38),
				])
				draw_colored_polygon(body, Color(0.28, 0.32, 0.26))
				draw_circle(c + Vector2(-s * 0.04, -s * 0.18), s * 0.12, Color(0.52, 0.58, 0.46))
				draw_circle(c + Vector2(-s * 0.08, -s * 0.19), s * 0.03, VisualTheme.COLOR_DANGER)
				draw_line(c + Vector2(s * 0.18, s * 0.05), c + Vector2(s * 0.34, -s * 0.18), Color(0.65, 0.62, 0.58), 3.0)
			"giant_rat":
				# Rato grande agachado com dorso arqueado, cauda e presas
				var rat: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.34, s * 0.24),
					c + Vector2(-s * 0.14, -s * 0.12),
					c + Vector2(s * 0.18, -s * 0.06),
					c + Vector2(s * 0.34, s * 0.18),
				])
				draw_colored_polygon(rat, Color(0.36, 0.28, 0.24))
				draw_circle(c + Vector2(-s * 0.20, 0.0), s * 0.035, VisualTheme.COLOR_DANGER)
				draw_line(c + Vector2(s * 0.28, s * 0.18), c + Vector2(s * 0.42, -s * 0.14), Color(0.62, 0.44, 0.42), 2.5)
			"carrion_crow":
				# Corvo carniceiro de asas abertas e bico longo
				var wings: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.40, -s * 0.16),
					c + Vector2(0, -s * 0.04),
					c + Vector2(s * 0.40, -s * 0.16),
					c + Vector2(s * 0.16, s * 0.22),
					c + Vector2(-s * 0.16, s * 0.22),
				])
				draw_colored_polygon(wings, Color(0.15, 0.16, 0.22))
				var beak: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.06, -s * 0.12),
					c + Vector2(-s * 0.28, -s * 0.06),
					c + Vector2(-s * 0.06, -s * 0.02),
				])
				draw_colored_polygon(beak, Color(0.75, 0.70, 0.55))
				draw_circle(c + Vector2(-s * 0.04, -s * 0.12), s * 0.03, VisualTheme.COLOR_GOLD)
			"plague_hound":
				# Cão de peste esquelético em postura de bote
				var hound: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.34, s * 0.10),
					c + Vector2(-s * 0.16, -s * 0.16),
					c + Vector2(s * 0.26, -s * 0.08),
					c + Vector2(s * 0.32, s * 0.26),
					c + Vector2(-s * 0.24, s * 0.28),
				])
				draw_colored_polygon(hound, Color(0.38, 0.24, 0.22))
				draw_circle(c + Vector2(-s * 0.20, -s * 0.08), s * 0.035, VisualTheme.COLOR_DANGER)
				for rib: int in 3:
					var rx: float = -s * 0.02 + rib * s * 0.08
					draw_line(c + Vector2(rx, -s * 0.06), c + Vector2(rx, s * 0.14), Color(0.78, 0.74, 0.68), 2.0)
			"rotten_executioner":
				# Elite: Carrasco de capuz pontudo e machado de guilhotina
				var exec_body: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.32, s * 0.40),
					c + Vector2(-s * 0.24, -s * 0.08),
					c + Vector2(0, -s * 0.38),
					c + Vector2(s * 0.24, -s * 0.08),
					c + Vector2(s * 0.32, s * 0.40),
				])
				draw_colored_polygon(exec_body, Color(0.26, 0.16, 0.18))
				draw_circle(c + Vector2(-s * 0.06, -s * 0.14), s * 0.03, VisualTheme.COLOR_DANGER)
				draw_circle(c + Vector2(s * 0.06, -s * 0.14), s * 0.03, VisualTheme.COLOR_DANGER)
				# Lâmina de machado pesado
				var axe: PackedVector2Array = PackedVector2Array([
					c + Vector2(s * 0.24, -s * 0.28),
					c + Vector2(s * 0.42, -s * 0.16),
					c + Vector2(s * 0.38, s * 0.12),
					c + Vector2(s * 0.22, -s * 0.02),
				])
				draw_colored_polygon(axe, Color(0.72, 0.74, 0.78))
			"bell_warden":
				# Mini Boss: Carcereiro do Sino com gaiola de ferro e sino rachado de bronze
				var warden: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.36, s * 0.40),
					c + Vector2(-s * 0.30, -s * 0.16),
					c + Vector2(s * 0.30, -s * 0.16),
					c + Vector2(s * 0.36, s * 0.40),
				])
				draw_colored_polygon(warden, Color(0.24, 0.22, 0.28))
				# Sino de bronze no peito/ombro
				var bell_poly: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.14, -s * 0.26),
					c + Vector2(s * 0.14, -s * 0.26),
					c + Vector2(s * 0.22, s * 0.12),
					c + Vector2(-s * 0.22, s * 0.12),
				])
				draw_colored_polygon(bell_poly, VisualTheme.COLOR_GOLD.darkened(0.2))
				draw_line(c + Vector2(0, -s * 0.12), c + Vector2(s * 0.08, s * 0.12), VisualTheme.COLOR_DANGER, 2.5)
			"gravedigger", _:
				# Chefe: O Coveiro com manto longo, pá enferrujada e lanterna dourada
				var boss_cloak: PackedVector2Array = PackedVector2Array([
					c + Vector2(-s * 0.38, s * 0.42),
					c + Vector2(-s * 0.26, -s * 0.14),
					c + Vector2(0, -s * 0.38),
					c + Vector2(s * 0.26, -s * 0.14),
					c + Vector2(s * 0.38, s * 0.42),
				])
				draw_colored_polygon(boss_cloak, Color(0.20, 0.13, 0.16))
				# Olhos sob o chapéu/capuz
				draw_circle(c + Vector2(-s * 0.07, -s * 0.16), s * 0.035, VisualTheme.COLOR_GOLD)
				draw_circle(c + Vector2(s * 0.07, -s * 0.16), s * 0.035, VisualTheme.COLOR_GOLD)
				# Pá enferrujada
				draw_line(c + Vector2(s * 0.28, s * 0.36), c + Vector2(s * 0.28, -s * 0.32), Color(0.52, 0.38, 0.26), 3.0)
				draw_rect(Rect2(c + Vector2(s * 0.20, -s * 0.38), Vector2(s * 0.16, s * 0.16)), Color(0.64, 0.66, 0.70), true)
				# Lanterna acesa na mão esquerda
				draw_circle(c + Vector2(-s * 0.28, s * 0.04), s * 0.09, VisualTheme.COLOR_GOLD)

	func _draw_mutation_aura(c: Vector2, r: float) -> void:
		var aura_color: Color = VisualTheme.COLOR_DANGER
		match mutation_id:
			"bloated":
				aura_color = Color(0.45, 0.78, 0.32, 0.45)
			"voracious":
				aura_color = Color(0.88, 0.18, 0.22, 0.50)
			"phantom":
				aura_color = Color(0.55, 0.75, 0.98, 0.45)
			"thorny":
				aura_color = Color(0.82, 0.62, 0.24, 0.50)
		draw_arc(c, r, 0.0, TAU, 24, aura_color, 3.0)


## Medalhão visual da moeda para o lance de Cara ou Coroa (GDD §7 e §19).
## Mostra formas e símbolos distintos para Cara (sol radiante) e Coroa (crânio/cruz sombria).
class CoinMedallion extends Control:
	var shown_side: int = CoinRules.HEADS
	var spinning: bool = false
	var spin_angle: float = 0.0

	func _init() -> void:
		custom_minimum_size = Vector2(176, 176)

	## A moeda gira de verdade enquanto `spinning` (antes o ângulo nunca avançava).
	func _process(delta: float) -> void:
		if spinning:
			spin_angle += delta * 15.0
			queue_redraw()

	func show_call_prompt() -> void:
		spinning = false
		spin_angle = 0.0
		queue_redraw()

	func set_side(side: int) -> void:
		shown_side = side
		spinning = false
		spin_angle = 0.0
		queue_redraw()

	func _draw() -> void:
		var c: Vector2 = size * 0.5
		var r: float = minf(size.x, size.y) * 0.42
		if r <= 4.0:
			return
		# Moedas pintadas (Cara dourada, Coroa prateada): giram achatando a largura e trocando de face (TASK-072).
		var heads_tex: Texture2D = UiKit.texture("coin_heads.png")
		var tails_tex: Texture2D = UiKit.texture("coin_tails.png")
		if heads_tex != null and tails_tex != null:
			var face: int = shown_side
			var squash: float = 1.0
			if spinning:
				squash = maxf(absf(cos(spin_angle)), 0.05)
				face = CoinRules.HEADS if cos(spin_angle) >= 0.0 else CoinRules.TAILS
			var tex: Texture2D = heads_tex if face == CoinRules.HEADS else tails_tex
			var half: float = minf(size.x, size.y) * 0.48
			draw_set_transform(c, 0.0, Vector2(squash, 1.0))
			draw_texture_rect(tex, Rect2(Vector2(-half, -half), Vector2(half * 2.0, half * 2.0)), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			return
		var rim_color: Color = VisualTheme.COLOR_GOLD if shown_side == CoinRules.HEADS else Color(0.75, 0.58, 0.34)
		var fill_color: Color = Color(0.32, 0.25, 0.12) if shown_side == CoinRules.HEADS else Color(0.22, 0.14, 0.16)
		draw_circle(c, r, fill_color)
		draw_arc(c, r, 0.0, TAU, 32, rim_color, 4.0)
		draw_arc(c, r * 0.82, 0.0, TAU, 28, rim_color.darkened(0.2), 1.5)

		if shown_side == CoinRules.HEADS:
			# CARA: Sol / Coroa radiante (GDD §19: forma e símbolo próprios)
			draw_circle(c, r * 0.28, VisualTheme.COLOR_GOLD)
			for i: int in 8:
				var a: float = spin_angle + i * (TAU / 8.0)
				var dir: Vector2 = Vector2(cos(a), sin(a))
				draw_line(c + dir * (r * 0.36), c + dir * (r * 0.66), VisualTheme.COLOR_GOLD, 2.5)
		else:
			# COROA: Cruz / Espinho de ferro carmesim (GDD §19: forma distinta da Cara)
			var d: float = r * 0.48
			draw_line(c + Vector2(0, -d), c + Vector2(0, d), VisualTheme.COLOR_DANGER, 3.5)
			draw_line(c + Vector2(-d * 0.75, -d * 0.2), c + Vector2(d * 0.75, -d * 0.2), VisualTheme.COLOR_DANGER, 3.5)
			draw_circle(c + Vector2(0, -d * 0.2), r * 0.16, rim_color)
