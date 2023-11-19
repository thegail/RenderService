//
//  uniforms.h
//  RenderService
//
//  Created by NUS17468-11-thegail on 11/18/23.
//

#ifndef uniforms_h
#define uniforms_h

#ifdef __METAL_VERSION__
#define float4x4 metal::float4x4
#else
#include <simd/simd.h>
#define float3 simd_float3
#define float4x4 simd_float4x4
#endif

struct Triangle {
	float3 normal;
	float3 color;
};

struct Uniforms {
	float3 camera;
	float4x4 matrix;
};

#endif /* uniforms_h */
