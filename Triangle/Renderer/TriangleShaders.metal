//
//  Triangle.metal
//  Triangle
//
//  Created by yinglun on 2020/8/4.
//  Copyright © 2020 little2s. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "TriangleShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float4 color;
} VertexOut;

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant VertexIn *vertices [[buffer(0)]],
                              constant vector_float2 &viewportSize [[buffer(1)]],
                              constant Uniforms &uniforms [[buffer(2)]])
{
    VertexOut out;

    // Index into the array of positions to get the current vertex.
    // The positions are specified in pixel dimensions (i.e. a value of 100
    // is 100 pixels from the origin).
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    pixelSpacePosition = (float4(pixelSpacePosition.x, pixelSpacePosition.y, 0, 1) * uniforms.m).xy;

    // To convert from positions in pixel space to positions in clip-space,
    //  divide the pixel coordinates by half the size of the viewport.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);

    // Pass the input color directly to the rasterizer.
    out.color = vertices[vertexID].color;

    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}
