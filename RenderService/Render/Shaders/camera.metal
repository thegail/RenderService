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

struct Lens {
	float3 centerpoint;
	float radius;
	float segment_length;
	float refractive_index;
	bool concave;
};

ray lens_refract(ray incident,
				 Lens lens,
				 float2 random) {
	ray ray;
	ray.direction = float3(0);
	
	float3 sphere_center = lens.centerpoint - float3(0, 0, lens.radius);
	float intersection_distance = intersect_sphere(incident.origin,
												   incident.direction,
												   sphere_center,
												   lens.radius,
												   lens.concave);
	if (isnan(intersection_distance) || intersection_distance < 0) return ray;
	float3 intersection_point = incident.origin + incident.direction * intersection_distance;
	float normal_scalar = lens.concave ? -1 : 1;
	float3 normal = normal_scalar * normalize(intersection_point - sphere_center);
	float3 new_direction = refract(incident.direction, normal, lens.refractive_index);
	
	ray.origin = intersection_point;
	ray.direction = new_direction;
	return ray;
}

ray thick_lens(uint2 screen_coords, uint2 screen_size, float2 random, constant Uniforms& uniforms) {
	float thickness = 0.1;
	
	Lens front;
	front.centerpoint = float3(0, 0, lens_distance);
	front.radius = 10;
	front.segment_length = -1;
	front.refractive_index = 1.52708;
	front.concave = true;
	
	Lens back;
	back.centerpoint = front.centerpoint + float3(0, 0, thickness);
	back.radius = 10;
	back.segment_length = -1;
	back.refractive_index = 1/1.52708;
	back.concave = true;
	
	ray ray;
	ray.origin = float3(0);
	ray.direction = normalize(sample_aperture(lens_distance + thickness - 0.05, sqrt(front.radius*front.radius - 0.05*0.05), random));
	ray.max_distance = INFINITY;
	
	ray = lens_refract(ray, front, random);
	ray = lens_refract(ray, back, random);
	
	float3x3 camera_to_world = float3x3(uniforms.camera.right,
										uniforms.camera.up,
										uniforms.camera.forward);
	ray.origin = camera_to_world * ray.origin + uniforms.camera.position;
	ray.direction = camera_to_world * ray.direction;
	
	return ray;
}

ray get_view_ray(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
	if (camera_type == 0) {
		return pinhole(screen_coords, screen_size, r, uniforms);
	} else if (camera_type == 1) {
		return thin_lens(screen_coords, screen_size, r, uniforms);
	} else if (camera_type == 2) {
		return thick_lens(screen_coords, screen_size, r, uniforms);
	} else {
		ray ray;
		return ray;
	}
}
