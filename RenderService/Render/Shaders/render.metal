//
//  render.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

#include "trace.h"

constant uint max_bounces [[function_constant(1)]];

constant unsigned int primes[] = {
	2,   3,  5,  7,
	11, 13, 17, 19,
	23, 29, 31, 37,
	41, 43, 47, 53,
	59, 61, 67, 71,
	73, 79, 83, 89,
	97, 101, 103, 107,
	109, 113, 127, 131,
	137, 139, 149, 151,
	157, 163, 167, 173,
	179, 181, 191, 193,
	197, 199, 211, 223,
	227, 229, 233, 239,
	241, 251, 257, 263,
	269, 271, 277, 281
};

float halton(unsigned int i, unsigned int d) {
	unsigned int b = primes[d];

	float f = 1.0f;
	float invB = 1.0f / b;

	float r = 0;

	while (i > 0) {
		f = f * invB;
		r = r + f * (i % b);
		i = i / b;
	}

	return r;
}

uint hash_position(uint2 coords, uint2 size) {
	uint offset = (coords.y * size.x + coords.x);
	offset = ((offset >> 16) ^ offset) * 0x45d9f3b;
	offset = ((offset >> 16) ^ offset) * 0x45d9f3b;
	offset = (offset >> 16) ^ offset;
	return offset;
}

kernel void render_image(uint2 screen_coords [[thread_position_in_grid]],
						 uint2 screen_size [[threads_per_grid]],
						 constant Uniforms& uniforms [[buffer(0)]],
						 primitive_acceleration_structure acceleration_structure [[buffer(1)]],
						 texture2d<float, access::read_write> output) {
	
	uint offset = hash_position(screen_coords, screen_size) + uniforms.frame;
	float2 view_r = float2(halton(offset, 0), halton(offset, 1));
	ray ray = get_view_ray(screen_coords, screen_size, view_r, uniforms);

	intersector<triangle_data> i;
	i.assume_geometry_type(geometry_type::triangle);
	i.force_opacity(forced_opacity::opaque);
	
	float3 accumulated_absorption = float3(1);
	float3 accumulated_emission = float3(0);
	for (uint bounce = 0; bounce < max_bounces; bounce++) {
		typename intersector<triangle_data>::result_type intersection;
		intersection = i.intersect(ray, acceleration_structure);
		if (intersection.type == intersection_type::none) {
			break;
		}
		
		float3 intersection_point = ray.origin + ray.direction * intersection.distance;
		Triangle triangle = *(const device Triangle*) intersection.primitive_data;
		
		accumulated_emission += accumulated_absorption * calculate_emission(triangle);
		float2 sample_r = float2(halton(offset, 2 + bounce * 3 + 0), halton(offset, 2 + bounce * 3 + 1));
		float3 new_direction = sample_direction(triangle, sample_r);
		accumulated_absorption *= calculate_absorption(triangle);
		
		float cont_prob = max3(accumulated_absorption.x, accumulated_absorption.y, accumulated_absorption.z);
		if (halton(offset, 2 + bounce * 3 + 2) > cont_prob) {
			break;
		}
		accumulated_absorption /= cont_prob;
		
		ray.origin = intersection_point + 1e-3 * triangle.normal;
		ray.direction = new_direction;
	}
	
	accumulated_emission += uniforms.frame * output.read(screen_coords).xyz;
	accumulated_emission /= uniforms.frame + 1;
	output.write(float4(accumulated_emission, 1), screen_coords);
}
