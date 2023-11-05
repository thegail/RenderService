//
//  uniforms.h
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/21/23.
//

#ifndef uniforms_h
#define uniforms_h

#ifdef __METAL_VERSION__
#define TEXTURE metal::texture2d<float, metal::access::sample>
#else
#include <simd/simd.h>
#define float3 simd_float3
#define TEXTURE uint64_t
#endif /* __METAL_VERSION__ */

struct Uniforms {
	uint frame;
};

struct Triangle {
	float3 normal;
	TEXTURE texture;
	// BYTE 0 FROM LSB: face_div
	// BYTE 1 FROM LSB: has_texture
	unsigned char primitive_flags;
	float3 color;
};

struct Lens {
	float3 centerpoint;
	float radius;
	float refractive_index;
	bool concave;
};

#endif /* uniforms_h */
