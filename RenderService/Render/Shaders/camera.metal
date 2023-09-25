//
//  camera.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include "trace.h"

ray get_view_ray(uint2 screen_coords, uint2 screen_size, float2 r, constant Uniforms& uniforms) {
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
