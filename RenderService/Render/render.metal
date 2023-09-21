//
//  render.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

#include <metal_stdlib>
#include "uniforms.h"
using namespace metal;
using namespace raytracing;

constant uint max_bounces [[function_constant(1)]];

ray get_view_ray(uint2 screen_coords, uint2 screen_size, uint offset, constant Uniforms& uniforms) {
	float2 pixel = float2(screen_coords);
	
	float2 uv = pixel / float2(screen_size.x);
	uv = uv * 2 - 1.0f;
	uv.y *= -1;
	
	ray ray;
	ray.origin = uniforms.camera.position;
	ray.direction = normalize(uv.x * uniforms.camera.right +
							  uv.y * uniforms.camera.up +
							  uniforms.camera.forward);
	ray.max_distance = INFINITY;
	
	return ray;
}

float3 calculate_emission(Triangle triangle) {
	float3 normal_color = triangle.normal * 0.5 + 0.5;
	return normal_color;
}

float3 sample_direction(Triangle triangle) {
	return float3(0);
}

float3 calculate_absorption(Triangle triangle) {
	return float3(1);
}

kernel void render_image(uint2 screen_coords [[thread_position_in_grid]],
						 uint2 screen_size [[threads_per_grid]],
						 constant Uniforms& uniforms [[buffer(0)]],
						 primitive_acceleration_structure acceleration_structure [[buffer(1)]],
						 texture2d<float, access::write> output) {
	ray ray = get_view_ray(screen_coords, screen_size, 0, uniforms);

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
		
		accumulated_emission += calculate_emission(triangle);
		float3 new_direction = sample_direction(triangle);
		accumulated_absorption *= calculate_absorption(triangle);
		
		ray.origin = intersection_point + 1e-3 * triangle.normal;
		ray.direction = new_direction;
	}
	
	output.write(float4(accumulated_emission, 1), screen_coords);
}
