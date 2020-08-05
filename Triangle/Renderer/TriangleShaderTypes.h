//
//  TriangleShaderTypes.h
//  Triangle
//
//  Created by yinglun on 2020/8/4.
//  Copyright © 2020 little2s. All rights reserved.
//

#ifndef TriangleShaderTypes_h
#define TriangleShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float4 color;
} VertexIn;

typedef struct {
    matrix_float4x4 m;
} Uniforms;

#endif /* TriangleShaderTypes_h */
