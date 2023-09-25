//
//  absorption.metal
//  RenderService
//
//  Created by NUS17468-11-thegail on 9/22/23.
//

#include "trace.h"

float3 calculate_absorption(Triangle triangle) {
	float3 normal_color = triangle.normal * 0.5 + 0.5;
	return normal_color;
}
