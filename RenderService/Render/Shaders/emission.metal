//
//  emission.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include <metal_stdlib>
#include "trace.h"
using namespace metal;

float3 calculate_emission(Triangle triangle) {
	if (triangle.color.x == 1) {
		return float3(3);
	} else {
		return float3(0);
	}
}
