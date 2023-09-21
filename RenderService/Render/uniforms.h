//
//  uniforms.h
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/21/23.
//

#ifndef uniforms_h
#define uniforms_h

#ifndef __METAL_VERSION__
#include <simd/simd.h>
#define float3 simd_float3
#endif /* __METAL_VERSION__ */

struct Camera {
	float3 position;
	float3 forward;
	float3 right;
	float3 up;
};

struct Uniforms {
	struct Camera camera;
	uint frame;
};

struct Triangle {
	float3 normal;
	float3 color;
	uint tex_id;
	unsigned char face_div;
};

#endif /* uniforms_h */