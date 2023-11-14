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

float chi(float x) {
	return sign(saturate(x));
}

float beckmann_distribution(float3 ms_normal, float3 normal, float alpha) {
	float m_dot_n = dot(ms_normal, normal);
	float exp_term = -(1/(m_dot_n * m_dot_n) - 1) / (alpha * alpha);
	float denom = M_PI_F * alpha * alpha * pow(m_dot_n, 4);
	return chi(m_dot_n) * exp(exp_term) / denom;
}

float beckmann_shadowing(float3 ray, float3 ms_normal, float3 normal, float alpha) {
	float n_dot_v = dot(normal, ray);
	float a = 1 / (alpha * (1 / (n_dot_v * n_dot_v) - 1));
	float a_sq = a * a;
	float r_term = (3.535 * a + 2.181 * a_sq) / (1 + 2.276 * a + 2.577 * a_sq);
	return chi(dot(ray, ms_normal) * dot(ray, normal)) * (a < 1.6 ? r_term : 1);
}

float phong_distribution(float3 ms_normal, float3 normal, float alpha) {
	return chi(dot(ms_normal, normal)) * (alpha + 2) * pow(dot(ms_normal, normal), alpha) / M_2_PI_F;
}

float phong_shadowing(float3 ray, float3 ms_normal, float3 normal, float alpha) {
	float n_dot_v = dot(normal, ray);
	float a = sqrt((0.5 * alpha + 1) / (1/(n_dot_v * n_dot_v) - 1));
	float a_sq = a * a;
	float r_term = (3.535 * a + 2.181 * a_sq) / (1 + 2.276 * a + 2.577 * a_sq);
	return chi(dot(ray, ms_normal) * dot(ray, normal)) * (a < 1.6 ? r_term : 1);
}

float ggx_distribution(float3 ms_normal, float3 normal, float alpha) {
	float alpha_sq = alpha * alpha;
	float m_dot_n = dot(ms_normal, normal);
	float sq_term = alpha_sq + 1/(m_dot_n * m_dot_n) - 1;
	float denom = M_PI_F * pow(m_dot_n, 4) * sq_term * sq_term;
	return alpha_sq * chi(m_dot_n) / denom;
}

float ggx_shadowing(float3 ray, float3 ms_normal, float3 normal, float alpha) {
	float n_dot_v = dot(normal, ray);
	float denom = 1 + sqrt(1 + alpha * alpha * (1/(n_dot_v * n_dot_v) - 1));
	return chi(dot(normal, ray) * dot(ms_normal, ray)) * 2 / denom;
}

float shadowing(float3 ray, float3 ms_normal, float3 normal, float alpha) {
	if (bsdf_type == 0) {
		return beckmann_shadowing(ray, ms_normal, normal, alpha);
	} else if (bsdf_type == 1) {
		return phong_shadowing(ray, ms_normal, normal, alpha);
	} else if (bsdf_type == 2) {
		return ggx_shadowing(ray, ms_normal, normal, alpha);
	} else {
		return 0;
	}
}

float dielectric_fresnal(float3 incident, float3 ms_normal, float refractive_index) {
	float c = abs(dot(incident, ms_normal));
	float g = sqrt(refractive_index * refractive_index - 1 + c * c);
	float outer_frac = (g - c) / (g + c);
	float inner_frac = (c * (g + c) - 1) / (c * (g - c) + 1);
	return 0.5 * outer_frac * outer_frac * (1 + inner_frac * inner_frac);
}

float schlick_fresnel(float3 incident, float3 ms_normal, float refractive_index) {
	float initial = (1 - refractive_index) / (1 + refractive_index);
	float m_dot_i = saturate(dot(ms_normal, incident));
	return initial * initial + (1 - initial * initial) * pow(1 + 1e-5 - m_dot_i, 5);
}

float distribution(float3 ms_normal, float3 normal, float alpha) {
	if (bsdf_type == 0) {
		return beckmann_distribution(ms_normal, normal, alpha);
	} else if (bsdf_type == 1) {
		return phong_distribution(ms_normal, normal, alpha);
	} else if (bsdf_type == 2) {
		return ggx_distribution(ms_normal, normal, alpha);
	} else {
		return 0;
	}
}

float geometry(float3 incident, float3 sample, float3 ms_normal, float3 normal, float alpha) {
	return shadowing(incident, ms_normal, normal, alpha) * shadowing(sample, ms_normal, normal, alpha);
}

float3 reflectance(float3 incident, float3 sample, float3 normal, float roughness) {
	float3 half_v = normalize(sample + incident);
	float fresnel = schlick_fresnel(incident, half_v, 1.5);
	float dist = distribution(half_v, normal, roughness);
	float geo = geometry(incident, sample, half_v, normal, roughness);
	float3 specular = fresnel * dist * geo / (4 * abs(dot(incident, normal)) * abs(dot(sample, normal)));
	return specular;
}

float3 transmittance(float3 incident, float3 sample, float3 normal, float roughness) {
	float eta_i = 1;
	float eta_o = 1.5;
	float3 half_v = normalize(-eta_i * incident - eta_o * sample);
	float vector_num = abs(dot(incident, half_v)) * abs(dot(sample, half_v));
	float vector_denom = abs(dot(incident, normal)) * abs(dot(sample, normal));
	float fresnel = eta_o * eta_o * (1 - schlick_fresnel(incident, half_v, 1.5));
	float geo = geometry(incident, sample, half_v, normal, roughness);
	float dist = distribution(half_v, normal, roughness);
	float eta_term = eta_i * dot(incident, half_v) + eta_o * dot(sample, half_v);
	return vector_num * fresnel * geo * dist / (eta_term * eta_term * vector_denom);
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
		roughness = 0;
	}
	
	if (sampling_strategy < 0.5) {
		return color;
	} else {
		float3 refl = reflectance(-incoming, sample, triangle.normal, roughness);
		float3 trans = transmittance(-incoming, sample, triangle.normal, roughness);
		return refl + trans;
	}
}
