//
//  DSRollScrollView.swift
//  BaviewKit
//
//  Created by Dfsx on 2020/9/16.
//  Copyright © 2020 dfsx. All rights reserved.
//

import UIKit

@objc public protocol DSRollScrollViewDelegate: NSObjectProtocol {
    
    @objc optional func rollScrollView(_ rollScrollView: DSRollScrollView, didClickItemAt index: Int)
}

public protocol DSRollScrollViewDataSource: NSObjectProtocol {

    func numberOfItems() -> Int
    func textForItem(_ item: Int) -> String
}

public class DSRollScrollView: UIView {

    var timer: Timer?
    public var scrollDuration = 0.5
    public var scrollInterval = 5.0
    public var currentIndex = 0
    
    public enum Direction {
        case up, down
    }
    public var scrollDirection = Direction.down
    
    public var textColor = UIColor.white {
        didSet {
            topLabel?.textColor = textColor
            bottomLabel?.textColor = textColor
        }
    }
    
    public var textFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            topLabel?.font = textFont
            bottomLabel?.font = textFont
        }
    }
    
    public var numberOfLines = 1 {
        didSet {
            topLabel?.numberOfLines = numberOfLines
            bottomLabel?.numberOfLines = numberOfLines
        }
    }
    
    public var singleItemShouldRoll = false
    
    public weak var delegate: DSRollScrollViewDelegate?
    public weak var dataSource: DSRollScrollViewDataSource?
    
    var topLabel: UILabel?
    var bottomLabel: UILabel?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    func setUpView() {
        
        clipsToBounds = true
        
        topLabel = UILabel()
        topLabel?.textColor = textColor
        topLabel?.font = textFont
        addSubview(topLabel!)
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(clickItem))
        topLabel?.addGestureRecognizer(topTapGesture)
        topLabel?.isUserInteractionEnabled = true

        
        bottomLabel = UILabel()
        bottomLabel?.textColor = textColor
        bottomLabel?.font = textFont
        addSubview(bottomLabel!)
        let bottomTapGesture = UITapGestureRecognizer(target: self, action: #selector(clickItem))
        bottomLabel?.addGestureRecognizer(bottomTapGesture)
        bottomLabel?.isUserInteractionEnabled = true
        
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        adjustPositionAndText()
    }
    
    func adjustPositionAndText() {
        
        if scrollDirection == .up {
            // set position
            topLabel?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
            bottomLabel?.frame = CGRect(origin: CGPoint(x: 0, y: frame.size.height), size: frame.size)
            
            // set text
            if let items = dataSource?.numberOfItems(), items > 0 {
                topLabel?.text = dataSource?.textForItem(currentIndex)
                bottomLabel?.text = dataSource?.textForItem((currentIndex + 1) % items)
            }
        } else {
            // set position
            topLabel?.frame = CGRect(origin: CGPoint(x: 0, y: -frame.size.height), size: frame.size)
            bottomLabel?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
            
            // set text
            if let items = dataSource?.numberOfItems(), items > 0 {
                topLabel?.text = dataSource?.textForItem((currentIndex + 1) % items)
                bottomLabel?.text = dataSource?.textForItem(currentIndex)
            }
        }

    }
    
    public func startRoll() {
        
        guard let items = dataSource?.numberOfItems(), items > 0 else { return }
        
        if items == 1 && !singleItemShouldRoll {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: scrollInterval, target: self, selector: #selector(roll), userInfo: nil, repeats: true)
    }
    
    public func stopRoll() {
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc func roll() {
        
        adjustPositionAndText()
        
        UIView.animate(withDuration: scrollDuration, animations: {
            //
            if self.scrollDirection == .up {
                
                self.topLabel?.frame = CGRect(origin: CGPoint(x: 0, y: -self.frame.size.height), size: self.frame.size)
                self.bottomLabel?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
            } else {
                
                self.topLabel?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
                self.bottomLabel?.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height), size: self.frame.size)
            }
            
        }) { (finished) in
            //
            if self.scrollDirection == .up {
                self.topLabel?.text = self.bottomLabel?.text
            } else {
                self.bottomLabel?.text = self.topLabel?.text
            }
            
            
            self.currentIndex += 1
            self.currentIndex %= self.dataSource!.numberOfItems()
        }
        
    }
    
    @objc func clickItem() {
        
        delegate?.rollScrollView?(self, didClickItemAt: currentIndex)
        
    }
    
}
