//
//  camera.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include "trace.h"

constant uchar camera_type [[function_constant(1)]];
constant float3 camera_position [[function_constant(2)]];
constant float3 camera_up [[function_constant(3)]];
constant float3 camera_right [[function_constant(4)]];
constant float3 camera_forward [[function_constant(5)]];

ray pinhole(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
	float2 pixel = float2(screen_coords);
	pixel += r;
	
	float2 uv = pixel / float2(screen_size.x);
	uv = uv * -2 + 1.0f;
	
	ray ray;
	ray.origin = camera_position;
	ray.direction = normalize(uv.x * camera_right +
							  uv.y * camera_up +
							  camera_forward);
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

float3 sample_rectangle(float2 dimensions, uint2 coords, uint2 size, float z) {
	return float3(dimensions * (2 * float2(coords) / float2(size) - 1), z);
}

constant float camera_aperture [[function_constant(10)]];
constant float focus_distance [[function_constant(11)]];
ray thin_lens(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
	float2 uv = float2(screen_coords) / float2(screen_size.x);
	uv = uv * 2 - 1.0f;
	uv.y *= -1;
	
	float3 focus_point_direction = normalize(float3(uv, 1));
	float focus_point_distance = focus_distance / focus_point_direction.z;
	float3 focus_point = focus_point_distance * focus_point_direction;
	
	float3 lens_sample = sample_aperture(0, camera_aperture, r);
	float3 ray_direction = normalize(focus_point - lens_sample);
	float3x3 camera_to_world = float3x3(camera_right,
										camera_up,
										camera_forward);
	
	ray ray;
	ray.origin = camera_to_world * lens_sample + camera_position;
	ray.direction = camera_to_world * ray_direction;
	ray.max_distance = INFINITY;
	
	return ray;
}

float solve_quadratic(float b, float c, bool largest) {
	float discr = b*b - 4*c;
	if (discr < 0) return NAN;
	if (discr == 0) return -0.5 * b;
	float q = (b > 0) ?
		-0.5 * (b + sqrt(discr)) :
		-0.5 * (b - sqrt(discr));
	float x0 = q;
	float x1 = c / q;
	return largest ? max(x0, x1) : min(x0, x1);
}

float intersect_sphere(float3 ray_origin,
					   float3 ray_direction,
					   float3 sphere_position,
					   float radius,
					   bool concave) {
	float3 center = ray_origin - sphere_position;
	float b = 2 * dot(ray_direction, center);
	float c = length_squared(center) - radius*radius;
	return solve_quadratic(b, c, concave);
}

ray lens_refract(ray incident,
				 Lens lens,
				 float2 random) {
	ray ray;
	ray.direction = float3(0);
	
	float concavity = lens.concave ? -1 : 1;
	float3 sphere_center = lens.centerpoint + concavity * float3(0, 0, lens.radius);
	float intersection_distance = intersect_sphere(incident.origin,
												   incident.direction,
												   sphere_center,
												   lens.radius,
												   lens.concave);
	if (isnan(intersection_distance) || intersection_distance < 0) return ray;
	float3 intersection_point = incident.origin + incident.direction * intersection_distance;
	float3 normal = concavity * normalize(intersection_point - sphere_center);
	float3 new_direction = refract(incident.direction, normal, lens.refractive_index);
	
	ray.origin = intersection_point;
	ray.direction = new_direction;
	return ray;
}

constant float lens_distance [[function_constant(12)]];
constant float2 sample_screen_size [[function_constant(13)]];
constant float aperture_distance [[function_constant(14)]];
constant uint lens_count [[function_constant(15)]];
ray thick_lens(uint2 screen_coords,
			   uint2 screen_size,
			   float2 random,
			   constant Uniforms& uniforms,
			   constant Lens* lenses) {
	ray ray;
	ray.origin = sample_rectangle(sample_screen_size, screen_coords, screen_size, -lens_distance);
	ray.direction = normalize(sample_aperture(-aperture_distance, camera_aperture, random) - ray.origin);
	ray.max_distance = INFINITY;
	
	for (uint i = 0; i < lens_count; i++) {
		Lens lens = lenses[i];
		ray = lens_refract(ray, lens, random);
	}
	
	float3x3 camera_to_world = float3x3(camera_right,
										camera_up,
										camera_forward);
	ray.origin = camera_to_world * ray.origin + camera_position;
	ray.direction = camera_to_world * ray.direction;
	
	return ray;
}

ray get_view_ray(uint2 screen_coords,
				 uint2 screen_size,
				 float2 r,
				 constant Uniforms& uniforms,
				 constant void* camera_buffer) {
	if (camera_type == 0) {
		return pinhole(screen_coords, screen_size, r, uniforms);
	} else if (camera_type == 1) {
		return thin_lens(screen_coords, screen_size, r, uniforms);
	} else if (camera_type == 2) {
		return thick_lens(screen_coords, screen_size, r, uniforms, (constant Lens*) camera_buffer);
	} else {
		ray ray;
		return ray;
	}
}
