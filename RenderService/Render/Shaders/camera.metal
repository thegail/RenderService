//
//  camera.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include "trace.h"

constant uchar camera_type [[function_constant(1)]];

ray pinhole(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
	float2 pixel = float2(screen_coords);
	pixel += r;
	
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

float3 sample_aperture(float length, float aperture, float2 random) {
	float theta = random.x * M_PI_2_F;
	float cos_theta;
	float sin_theta = sincos(theta, cos_theta);
	float radius = aperture * random.y;
	return float3(cos_theta * radius, sin_theta * radius, length);
}

constant float camera_aperture [[function_constant(10)]];
constant float lens_distance [[function_constant(11)]];
constant float focus_distance [[function_constant(12)]];
ray thin_lens(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
	float2 uv = float2(screen_coords) / float2(screen_size.x);
	uv = uv * 2 - 1.0f;
	uv.y *= -1;
	
	float3 focus_point_direction = normalize(float3(uv, 1));
	float focus_point_distance = focus_distance / focus_point_direction.z;
	float3 focus_point = focus_point_distance * focus_point_direction;
	
	float3 lens_sample = sample_aperture(lens_distance, camera_aperture, r);
	float3 ray_direction = normalize(focus_point - lens_sample);
	float3x3 camera_to_world = float3x3(uniforms.camera.right,
										uniforms.camera.up,
										uniforms.camera.forward);
	
	ray ray;
	ray.origin = camera_to_world * lens_sample + uniforms.camera.position;
	ray.direction = camera_to_world * ray_direction;
	ray.max_distance = INFINITY;
	
	return ray;
}

ray get_view_ray(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
	if (camera_type == 0) {
		return pinhole(screen_coords, screen_size, r, uniforms);
	} else if (camera_type == 1) {
		return thin_lens(screen_coords, screen_size, r, uniforms);
	} else {
		ray ray;
		return ray;
	}
}
