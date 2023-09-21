//
//  render.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/20/23.
//

#include <metal_stdlib>
using namespace metal;
using namespace raytracing;

kernel void render_image(uint2 screen_coords [[thread_position_in_grid]],
						 uint2 screen_size [[threads_per_grid]],
						 constant void* uniforms [[buffer(0)]],
						 texture2d<float, access::write> output) {
	output.write(float4(0), screen_coords);
}
