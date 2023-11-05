//
//  emission.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include <metal_stdlib>
#include "trace.h"
using namespace metal;

float2 calc_tex_coords(float2 b_coords, uchar face_div);

float3 calculate_emission(Triangle triangle, float2 triangle_coords) {
	if (triangle.color.x == 1) {
		if (triangle.primitive_flags & 0b10) {
			float2 uv = calc_tex_coords(triangle_coords, triangle.primitive_flags & 0b1);
			constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
			return float3(6) * pow(triangle.texture.sample(s, uv).xyz, 2.2);
		} else {
			return float3(3);
		}
	} else {
		return float3(0);
	}
}
