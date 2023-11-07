//
//  post.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/21/23.
//

#include <metal_stdlib>
using namespace metal;

float3 hdr(float3 color) {
	return color / (color + float3(1));
}

float3 gamma_correct(float3 color, float gamma) {
	return pow(color, (1 / gamma));
}

kernel void post(ushort2 coords [[thread_position_in_grid]],
				 texture2d<float> input [[texture(0)]],
				 texture2d<float, access::write> output [[texture(1)]]) {
	float3 color = input.read(coords).xyz;
	color = hdr(color);
	color = gamma_correct(color, 2.8);
	output.write(float4(color, 1), coords);
}
