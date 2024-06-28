shader_type canvas_item;

uniform vec3 ColorTopLeft;
uniform float TopLeftAlpha:hint_range(0,1);

uniform vec3 ColorTopRight2;
uniform float ToprightAlpha2:hint_range(0,1);

uniform vec3 ColordownLeft2;
uniform float downLeftAlpha2:hint_range(0,1);

uniform vec3 ColordownRight3;
uniform float downrightAlpha3:hint_range(0,1);


// Gradient4Corners

vec4 gradient4cornersFunc(vec2 _uv_c0rner, vec4 _top_left_c0rner, vec4 _top_right_c0rner, vec4 _bottom_left_c0rner, vec4 _bottom_right_c0rner){
	vec4 _c0l0r_t0p_c0rner = mix(_top_left_c0rner, _top_right_c0rner, _uv_c0rner.x);
	vec4 _c0l0r_b0tt0m_c0rner = mix(_bottom_left_c0rner, _bottom_right_c0rner, _uv_c0rner.x);
	return mix(_c0l0r_t0p_c0rner, _c0l0r_b0tt0m_c0rner, _uv_c0rner.y);
}


void fragment() {
// Input:3
	vec3 n_out3p0 = vec3(UV, 0.0);

// VectorUniform:4
	vec3 n_out4p0 = ColorTopLeft;

// ScalarUniform:5
	float n_out5p0 = TopLeftAlpha;

// VectorUniform:7
	vec3 n_out7p0 = ColorTopRight2;

// ScalarUniform:6
	float n_out6p0 = ToprightAlpha2;

// VectorUniform:10
	vec3 n_out10p0 = ColordownLeft2;

// ScalarUniform:11
	float n_out11p0 = downLeftAlpha2;

// VectorUniform:8
	vec3 n_out8p0 = ColordownRight3;

// ScalarUniform:9
	float n_out9p0 = downrightAlpha3;

// Gradient4Corners:2
	vec3 n_out2p0;
	float n_out2p1;
	{
		vec4 n_out2p0n_out2p1 = gradient4cornersFunc(n_out3p0.xy, vec4(n_out4p0, n_out5p0), vec4(n_out7p0, n_out6p0), vec4(n_out10p0, n_out11p0), vec4(n_out8p0, n_out9p0));
		n_out2p0 = n_out2p0n_out2p1.rgb;
		n_out2p1 = n_out2p0n_out2p1.a;
	}

// Output:0
	COLOR.rgb = n_out2p0;
	COLOR.a = n_out2p1;

}


