//
//  trace.h
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#ifndef trace_h
#define trace_h

#include <metal_stdlib>
#include "../uniforms.h"
using namespace metal;
using namespace raytracing;

ray get_view_ray(uint2 screen_coords,
				 uint2 screen_size,
				 float2 r,
				 constant Uniforms& uniforms,
				 constant void* camera_buffer);
float3 calculate_emission(Triangle triangle, float2 triangle_coords);
float3 sample_direction(Triangle triangle, float3 incident, float2 r);
float3 calculate_absorption(Triangle triangle, float2 triangle_coords, float3 incident, float3 sample);

#endif /* trace_h */
