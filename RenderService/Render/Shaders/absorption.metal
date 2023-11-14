//
//  absorption.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include "trace.h"

constant uchar bsdf_type [[function_constant(20)]];

float2 calc_tex_coords(float2 b_coords, uchar face_div) {
	float3 point_coefficients = float3(1 - b_coords.x - b_coords.y, b_coords);
	
	float3x2 triangle_points;
	if (face_div == 0) {
		triangle_points = float3x2(float2(0, 0), float2(1, 0), float2(0, 1));
	} else {
		triangle_points = float3x2(float2(1, 1), float2(0, 1), float2(1, 0));
	}
	
	return triangle_points * point_coefficients;
}

float3 calculate_absorption(Triangle triangle,
							float2 triangle_coords,
							float3 incoming,
							float3 sample,
							float sampling_strategy) {
	float3 color;
	float roughness;
	if (triangle.primitive_flags & 0b10) {
		float2 uv = calc_tex_coords(triangle_coords, triangle.primitive_flags & 0b1);
		constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::nearest);
		color = pow(triangle.texture.sample(s, uv).xyz, 2.8);
		roughness = 1;
	} else {
		color = triangle.normal * 0.5 + 0.5;
		roughness = 0.5;
	}
	
	return color;
}
