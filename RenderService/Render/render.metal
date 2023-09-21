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
	if (triangle.color.x == 1) {
		return float3(4);
	} else {
		return float3(0);
	}
}

float3 align_hemisphere_with_normal(float3 sample, float3 normal) {
	// Set the "up" vector to the normal
	float3 up = normal;

	// Find an arbitrary direction perpendicular to the normal, which becomes the
	// "right" vector.
	float3 right = normalize(cross(normal, float3(0.0072f, 1.0f, 0.0034f)));

	// Find a third vector perpendicular to the previous two, which becomes the
	// "forward" vector.
	float3 forward = cross(right, up);

	// Map the direction on the unit hemisphere to the coordinate system aligned
	// with the normal.
	return sample.x * right + sample.y * up + sample.z * forward;
}

float3 sample_direction(Triangle triangle, uint frame) {
	float rx = float(frame % 32) / 32;
	float ry = float(frame) / 1024;
	
	float phi = 2 * M_PI_F * rx;
	float cos_phi;
	float sin_phi = sincos(phi, cos_phi);

	float cos_theta = ry;
	float sin_theta = sqrt(1 - cos_theta * cos_theta);

	float3 sample = float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
	return align_hemisphere_with_normal(sample, triangle.normal);
}

float3 calculate_absorption(Triangle triangle) {
	float3 normal_color = triangle.normal * 0.5 + 0.5;
	return normal_color;
}

kernel void render_image(uint2 screen_coords [[thread_position_in_grid]],
						 uint2 screen_size [[threads_per_grid]],
						 constant Uniforms& uniforms [[buffer(0)]],
						 primitive_acceleration_structure acceleration_structure [[buffer(1)]],
						 texture2d<float, access::read_write> output) {
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
		
		accumulated_emission += accumulated_absorption * calculate_emission(triangle);
		float3 new_direction = sample_direction(triangle, uniforms.frame);
		accumulated_absorption *= calculate_absorption(triangle);
		
		ray.origin = intersection_point + 1e-3 * triangle.normal;
		ray.direction = new_direction;
	}
	
	accumulated_emission += uniforms.frame * output.read(screen_coords).xyz;
	accumulated_emission /= uniforms.frame + 1;
	output.write(float4(accumulated_emission, 1), screen_coords);
}
