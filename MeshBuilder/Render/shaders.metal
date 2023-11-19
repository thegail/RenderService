//
//  shaders.metal
//  MeshBuilder
//
//  Created by NUS17468-11-thegail on 11/18/23.
//

#include <metal_stdlib>
#include "uniforms.h"
using namespace metal;

struct RasterizerData {
	float3 position;
	float4 out [[position]];
	uint primitive_id;
};

vertex RasterizerData render_vertex(uint vertex_id [[vertex_id]],
									constant float3* vertices [[buffer(0)]],
									constant Uniforms& uniforms [[buffer(1)]]) {
	RasterizerData out;
	out.position = vertices[vertex_id];
	out.out = uniforms.matrix * float4(out.position, 1);
	out.primitive_id = vertex_id / 3;
	return out;
}

fragment float4 render_fragment(RasterizerData in [[stage_in]],
								constant Triangle* primitives [[buffer(0)]],
								constant Uniforms& uniforms [[buffer(1)]]) {
	Triangle primitive = primitives[in.primitive_id];
	float3 incident = uniforms.camera - in.position;
	float3 color = primitive.normal * 0.5 + 0.5;
	float shade = dot(incident, primitive.normal);
	return float4(shade * color, 1);
}
