//
//  HorizontalScroller.swift
//  BlueLibrarySwift
//
//  Created by Đinh Văn Nhật on 2014/12/29.
//  Copyright (c) 2014年 Dinh Van Nhat. All rights reserved.
//

import UIKit

@objc protocol HorizontalScrollerDelegate {
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index:Int) -> UIView
    
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index:Int)
    
    optional func initialViewIndex(scroller: HorizontalScroller) -> Int
}

class HorizontalScroller: UIView {
    weak var delegate: HorizontalScrollerDelegate?
    
    private let VIEW_PADDING = 10
    private let VIEW_DIMENSIONS = 100
    private let VIEWS_OFFSET = 100
    
    private var scroller : UIScrollView!
    
    var viewArray = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScrollView()
    }
    
    func initializeScrollView() {
        scroller = UIScrollView()
        addSubview(scroller)
        
        scroller.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("scrollerTapped:"))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    
    func scrollerTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(gesture.view)
        if let delegate = self.delegate {
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
                let view = scroller.subviews[index] as UIView
                if CGRectContainsPoint(view.frame, location) {
                    delegate.horizontalScrollerViewAtIndex(self, index: index)
                    scroller.setContentOffset(CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0), animated: true)
                    break
                }
            }
        }
    }
    
    func viewAtIndex(index :Int) -> UIView {
        return viewArray[index]
    }
    
    func reload() {
        if let delegate = self.delegate {
            viewArray = []
            let views: NSArray = scroller.subviews
            
            views.enumerateObjectsUsingBlock({ (object: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                object.removeFromSuperview()
            })
            
            var xValue = VIEWS_OFFSET
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
                xValue += VIEW_PADDING
                let view = delegate.horizontalScrollerViewAtIndex(self, index: index)
                view.frame = CGRectMake(CGFloat(xValue), CGFloat(VIEW_PADDING), CGFloat(VIEW_DIMENSIONS), CGFloat(VIEW_DIMENSIONS))
                scroller.addSubview(view)
                xValue += VIEW_DIMENSIONS + VIEW_PADDING
                
                viewArray.append(view)
            }
            
            scroller.contentSize = CGSizeMake(CGFloat(xValue + VIEWS_OFFSET), frame.size.height)
            
            if let initialView = delegate.initialViewIndex?(self) {
                scroller.setContentOffset(CGPointMake(CGFloat(initialView)*CGFloat((VIEW_DIMENSIONS + (2 * VIEW_PADDING))), 0), animated: true
                )
            }
        }
    }
    
    override func didMoveToSuperview() {
        reload()
    }
    
    func centerCurrentView() {
        var xFinal = scroller.contentOffset.x + CGFloat((VIEWS_OFFSET/2) + VIEW_PADDING)
        let viewIndex = xFinal / CGFloat(VIEW_DIMENSIONS + 2 * VIEW_PADDING)
        xFinal = viewIndex * CGFloat(VIEW_DIMENSIONS + 2 * VIEW_PADDING)
        scroller.setContentOffset(CGPointMake(xFinal, 0), animated: true)
        if let delegate = self.delegate {
            delegate.horizontalScrollerClickedViewAtIndex(self, index: Int(viewIndex))
        }
    }
}

extension HorizontalScroller: UIScrollViewDelegate {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentView()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        centerCurrentView()
    }
}

