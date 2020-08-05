//
//  Renderer.swift
//  Triangle
//
//  Created by yinglun on 2020/8/4.
//  Copyright © 2020 little2s. All rights reserved.
//

import UIKit
import Metal

class Renderer {
    
    private let device: MTLDevice!
    
    private var pipelineState: MTLRenderPipelineState!
    
    private var commandQueue: MTLCommandQueue!
    
    private var vertexBuffer: MTLBuffer!
        
    private(set) weak var layer: CAMetalLayer?
    
    init(layer: CAMetalLayer) {
        self.layer = layer
        
        //build device
        self.device = MTLCreateSystemDefaultDevice()
        self.layer?.device = self.device
        self.layer?.pixelFormat = .bgra8Unorm
        self.layer?.contentsScale = UIScreen.main.scale
        
        self.commandQueue = self.device.makeCommandQueue()
        
        //build pipeline
        let library = self.device.makeDefaultLibrary()
        
        let vertexFunc = library?.makeFunction(name: "vertexShader")
        let fragmentFunc = library?.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        self.pipelineState = try? self.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        //build vertex buffers
        var vertices: [VertexIn] = [
            VertexIn(position: SIMD2<Float>(250, -250), color: SIMD4<Float>(1, 0, 0, 1)),
            VertexIn(position: SIMD2<Float>(-250, -250), color: SIMD4<Float>(0, 1, 0, 1)),
            VertexIn(position: SIMD2<Float>(0, 250), color: SIMD4<Float>(0, 0, 1, 1))
        ]
        
        self.vertexBuffer = self.device.makeBuffer(bytes: &vertices, length: vertices.count * MemoryLayout.size(ofValue: vertices[0]), options: .storageModeShared)
        
        self.startTimer()
    }
    
    deinit {
        self.stopTimer()
    }
    
    private func redraw() {
        guard let layer = self.layer, let drawable = layer.nextDrawable() else { return }
        let texture = drawable.texture
        
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = texture
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = .clear
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        
        print(texture.width)
        
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass)!
        commandEncoder.setRenderPipelineState(self.pipelineState)
        commandEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        var viewportSize = SIMD2<Float>(Float(layer.frame.width * layer.contentsScale), Float(layer.frame.height * layer.contentsScale))
        commandEncoder.setVertexBytes(&viewportSize, length: MemoryLayout.size(ofValue: viewportSize), index: 1)
        var t = CGAffineTransform.identity
        t = t.concatenating(CGAffineTransform(translationX: 0, y: 250/3.0))
        t = t.concatenating(CGAffineTransform(rotationAngle: self.rotation()))
        t = t.concatenating(CGAffineTransform(translationX: 0, y: -250/3.0))
        let transform = CATransform3DMakeAffineTransform(t)
        var uniforms = Uniforms(m: transform.simdMatrix)
        commandEncoder.setVertexBytes(&uniforms, length: MemoryLayout.size(ofValue: uniforms), index: 2)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private var timer: CADisplayLink?
    
    private func startTimer() {
        let link = CADisplayLink(target: self, selector: #selector(onTimer))
        link.add(to: RunLoop.main, forMode: .common)
        self.timer = link
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func onTimer() {
        redraw()
    }
    
    private var startTime: TimeInterval?
    
    private func rotation() -> CGFloat {
        if let startTime = self.startTime {
            return CGFloat(CFAbsoluteTimeGetCurrent() - startTime) / 4 * (-.pi) * 2
        }
        self.startTime = CFAbsoluteTimeGetCurrent()
        return 0
    }
}


extension CATransform3D {
    var simdMatrix: matrix_float4x4 {
        var r = matrix_float4x4()
        
        r[0][0] = Float(m11)
        r[1][0] = Float(m12)
        r[2][0] = Float(m13)
        r[3][0] = Float(m14)
        
        r[0][1] = Float(m21)
        r[1][1] = Float(m22)
        r[2][1] = Float(m23)
        r[3][1] = Float(m24)
        
        r[0][2] = Float(m31)
        r[1][2] = Float(m32)
        r[2][2] = Float(m33)
        r[3][2] = Float(m34)
        
        r[0][3] = Float(m41)
        r[1][3] = Float(m42)
        r[2][3] = Float(m43)
        r[3][3] = Float(m44)

        return r
    }
}
