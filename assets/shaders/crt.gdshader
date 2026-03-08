shader_type canvas_item;

// CRT Post-Processing Shader for Signal Lost
// Applied via a full-screen ColorRect on a top-level CanvasLayer.
// Features: scanlines, phosphor glow, barrel curvature, vignette, chromatic aberration.
// All effects scaled by a single intensity uniform (0.0 = off, 1.0 = full).

uniform float intensity : hint_range(0.0, 1.0) = 0.7;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Scanline parameters
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.15;
uniform float scanline_frequency : hint_range(100.0, 800.0) = 400.0;

// Curvature
uniform float curvature : hint_range(0.0, 0.1) = 0.02;

// Vignette
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.3;

// Chromatic aberration
uniform float chroma_offset : hint_range(0.0, 5.0) = 1.0;

// Phosphor glow
uniform float glow_strength : hint_range(0.0, 0.5) = 0.08;

// Apply barrel distortion for CRT curvature
vec2 barrel_distort(vec2 uv, float k) {
	vec2 centered = uv - 0.5;
	float r2 = dot(centered, centered);
	vec2 distorted = centered * (1.0 + k * r2);
	return distorted + 0.5;
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// Apply curvature (scaled by intensity)
	float curve_amount = curvature * intensity;
	if (curve_amount > 0.0) {
		uv = barrel_distort(uv, curve_amount);
	}

	// Out-of-bounds check (black edges from curvature)
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	// Base color
	vec3 col = texture(screen_texture, uv).rgb;

	// Chromatic aberration (scaled by intensity)
	float ca = chroma_offset * intensity / 1280.0;  // Normalized to viewport width
	if (ca > 0.0) {
		float r = texture(screen_texture, uv + vec2(ca, 0.0)).r;
		float g = col.g;
		float b = texture(screen_texture, uv - vec2(ca, 0.0)).b;
		col = vec3(r, g, b);
	}

	// Phosphor glow — simple bloom approximation (box blur)
	float gs = glow_strength * intensity;
	if (gs > 0.0) {
		vec2 pixel = vec2(1.0 / 1280.0, 1.0 / 720.0);
		vec3 glow = vec3(0.0);
		glow += texture(screen_texture, uv + vec2(-pixel.x, 0.0)).rgb;
		glow += texture(screen_texture, uv + vec2(pixel.x, 0.0)).rgb;
		glow += texture(screen_texture, uv + vec2(0.0, -pixel.y)).rgb;
		glow += texture(screen_texture, uv + vec2(0.0, pixel.y)).rgb;
		glow += texture(screen_texture, uv + vec2(-pixel.x, -pixel.y)).rgb;
		glow += texture(screen_texture, uv + vec2(pixel.x, pixel.y)).rgb;
		glow *= gs / 6.0;
		col += glow;
	}

	// Scanlines
	float sl = scanline_strength * intensity;
	if (sl > 0.0) {
		float scanline = sin(uv.y * scanline_frequency * 3.14159) * 0.5 + 0.5;
		col *= 1.0 - sl * (1.0 - scanline);
	}

	// Vignette
	float vig = vignette_strength * intensity;
	if (vig > 0.0) {
		vec2 vig_uv = uv - 0.5;
		float vig_amount = 1.0 - dot(vig_uv, vig_uv) * (vig * 4.0);
		col *= clamp(vig_amount, 0.0, 1.0);
	}

	// Subtle green tint (phosphor monitor feel)
	col *= vec3(0.95, 1.0, 0.97) + vec3(0.0, 0.02, 0.01) * intensity;

	COLOR = vec4(col, 1.0);
}
