//
//  ViewController.swift
//  Triangle
//
//  Created by yinglun on 2020/8/4.
//  Copyright © 2020 little2s. All rights reserved.
//

import UIKit

class MetalView: UIView {
    override class var layerClass: AnyClass { CAMetalLayer.self }
    var metalLayer: CAMetalLayer { layer as! CAMetalLayer }
}

class ViewController: UIViewController {
    
    private let metalView = MetalView()
    
    private var render: Renderer?

    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.frame = view.bounds
        metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(metalView)
        
        render = Renderer(layer: metalView.metalLayer)
    }

}

