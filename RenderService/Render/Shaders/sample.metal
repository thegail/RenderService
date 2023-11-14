//
//  sample.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include "trace.h"

float3 align_hemisphere_with_normal(float3 sample, float3 normal) {
	float3 up = normal;
	float3 right = normalize(cross(normal, float3(0.0072f, 1.0f, 0.0034f)));
	float3 forward = cross(right, up);
	return sample.x * right + sample.y * up + sample.z * forward;
}

float3 uniform_sample(Triangle triangle, float3 incident, float2 r) {
	float phi = 2 * M_PI_F * r.x;
	float cos_phi;
	float sin_phi = sincos(phi, cos_phi);

	float theta = M_PI_2_F * r.y;
	float cos_theta;
	float sin_theta = sincos(theta, cos_theta);
	
	float3 sample = float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
	return align_hemisphere_with_normal(sample, triangle.normal);
}

float3 cosine_sample(Triangle triangle, float3 incident, float2 r) {
	float phi = 2 * M_PI_F * r.x;
	float cos_phi;
	float sin_phi = sincos(phi, cos_phi);

	float cos_theta = r.y;
	float sin_theta = sqrt(1 - cos_theta * cos_theta);
	
	float3 sample = float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
	return align_hemisphere_with_normal(sample, triangle.normal);
}

float3 beckmann_sample(Triangle triangle, float3 incident, float2 r) {
	float phi = M_2_PI_F * r.x;
	float cos_phi;
	float sin_phi = sincos(phi, cos_phi);
	
	float alpha = triangle.primitive_flags & 0b10 ? 1 : 0;
	float t_sq_theta = -alpha * alpha * log(1 - r.y);
	float cos_theta = rsqrt(1 + t_sq_theta);
	float sin_theta = sqrt(1 - cos_theta * cos_theta);
	
	float3 sample = float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
	float3 normal = align_hemisphere_with_normal(sample, triangle.normal);
	return reflect(incident, normal);
}

float3 phong_sample(Triangle triangle, float3 incident, float2 r) {
	float phi = M_2_PI_F * r.x;
	float cos_phi;
	float sin_phi = sincos(phi, cos_phi);
	
	float alpha = triangle.primitive_flags & 0b10 ? 1 : 0;
	float cos_theta = pow(r.y, 1 / (alpha + 2));
	float sin_theta = sqrt(1 - cos_theta * cos_theta);
	
	float3 sample = float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
	float3 normal = align_hemisphere_with_normal(sample, triangle.normal);
	return reflect(incident, normal);
}

float3 ggx_sample(Triangle triangle, float3 incident, float2 r) {
	float phi = M_2_PI_F * r.x;
	float cos_phi;
	float sin_phi = sincos(phi, cos_phi);
	
	float alpha = triangle.primitive_flags & 0b10 ? 1 : 0;
	float tan_theta = alpha * sqrt(r.y) * rsqrt(1 - r.y);
	float cos_theta = rsqrt(1 + tan_theta * tan_theta);
	float sin_theta = sqrt(1 - cos_theta * cos_theta);
	
	float3 sample = float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
	float3 normal = align_hemisphere_with_normal(sample, triangle.normal);
	return reflect(incident, normal);
}

float3 sample_direction(Triangle triangle, float3 incident, float2 r) {
	return uniform_sample(triangle, incident, r);
}
