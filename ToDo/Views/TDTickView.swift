//
//  TDTickView.swift
//  ToDo
//
//  Created by Rick Wierenga on 01/02/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import UIKit

class TDTickView: UIControl {
    
    // MARK: - Properties
    public var isDone = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Control life cycle
    
    override func draw(_ rect: CGRect) {
        if isDone {
            let width = self.frame.width
            let height = self.frame.height
            
            // draw background
            let b = UIBezierPath(rect: rect)
            self.tintColor.setFill()
            b.fill()
            
            // draw tick
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: width / 3, y: height / 2))
            path.addLine(to: CGPoint(x: width / 2, y: 2 * height / 3))
            path.addLine(to: CGPoint(x: 2 * width / 3, y: height / 3))
            UIColor.white.setStroke()
            path.lineWidth = (width * height) / 500
            path.stroke()
        }
    }
    
    // MARK: - Helpers
    func setup() {
        self.layer.cornerRadius = self.frame.height / 4
        self.layer.borderWidth = 1000
        self.clipsToBounds = true
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 2
    }
    
    // MARK: - UI actions
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDone.toggle()
        sendActions(for: .valueChanged)
    }
}
