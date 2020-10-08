//
//  ViewController.swift
//  BlockVerticalScroll
//
//  Created by Manolis Katsifarakis on 08/01/2019.
//  Copyright © 2019 Emmanouil Katsifarakis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: DirectionLockingScrollView!
    
    var allowScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isHorizontalScrollingEnabled = false
        scheduleTimer(2)
    }
    
    var timer:Timer?
    var currentPageMultiplayer = 0
    func scheduleTimer(_ timeInterval: TimeInterval){
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerCall), userInfo: nil, repeats: false)
    }

    @objc func timerCall(){
        print("Timer executed")
        
        currentPageMultiplayer = currentPageMultiplayer + 1
        
        if (currentPageMultiplayer == 2) {
            currentPageMultiplayer = 0
        }

        scrollToPage(pageToMove: currentPageMultiplayer)
        
        scheduleTimer(2)
    }
    
    func scrollToPage(pageToMove: Int) {
        print ("new one")
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(pageToMove)
        frame.origin.y = -35
        scrollView.scrollRectToVisible(frame, animated: true)
        
    }
    
    @IBAction func action() {
        print("GOA")
    }
}

class DirectionLockingScrollView: UIScrollView {
    var isHorizontalScrollingEnabled = true
    var isVerticalScrollingEnabled = true
    
    /// The control scrollview is added below the `DirectionLockingScrollView`
    /// and is used to implement all native scrollview behaviours (such as bouncing)
    /// based on user input.
    ///
    /// It is required to be able to change the bounds of the `DirectionLockingScrollView`
    /// while maintaining scrolling in only one direction and allowing for setting the contentOffset
    /// (changing scrolling for any axis - even the disabled ones) programmatically.
    private let _controlScrollView = UIScrollView(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installCustomScrollView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installCustomScrollView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCustomScrollViewFrame()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else {
            _controlScrollView.removeFromSuperview()
            return
        }
        
        superview.insertSubview(_controlScrollView, belowSubview: self)
        updateCustomScrollViewFrame()
    }
    
    // MARK: - UIEvent propagation
    
    func viewIgnoresEvents(_ view: UIView?) -> Bool {
        let viewIgnoresEvents =
            view == nil ||
            view == self ||
            !view!.isUserInteractionEnabled ||
            !(view is UIControl && (view!.gestureRecognizers ?? []).count == 0)
        
        return viewIgnoresEvents
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if viewIgnoresEvents(view) {
            return _controlScrollView
        }
        
        return view
    }
    
    // MARK: - Main scrollview settings propagation to `controlScrollView`
    
    override var contentInset: UIEdgeInsets {
        didSet {
            _controlScrollView.contentInset = contentInset
        }
    }
    
    override var contentScaleFactor: CGFloat {
        didSet {
            _controlScrollView.contentScaleFactor = contentScaleFactor
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            _controlScrollView.contentSize = contentSize
        }
    }
    
    override var bounces: Bool {
        didSet {
            _controlScrollView.bounces = bounces
        }
    }
    
    override var bouncesZoom: Bool {
        didSet {
            _controlScrollView.bouncesZoom = bouncesZoom
        }
    }
}

extension DirectionLockingScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBoundsFromCustomScrollView(scrollView)
    }
}

private extension DirectionLockingScrollView {
    /// Propagates `controlScrollView` bounds to the actual scrollview.
    /// - Parameter scrollView: If the scrollview provided is not the `controlScrollView`
    //                          the main scrollview bounds are not updated.
    func updateBoundsFromCustomScrollView(_ scrollView: UIScrollView) {
        if scrollView != _controlScrollView {
            return
        }
        
        var newBounds = scrollView.bounds.origin
        if !isHorizontalScrollingEnabled {
            newBounds.x = self.contentOffset.x
        }
        
        if !isVerticalScrollingEnabled {
            newBounds.y = self.contentOffset.y
        }

        bounds.origin = newBounds
    }
    
    func installCustomScrollView() {
        _controlScrollView.delegate = self
        _controlScrollView.contentSize = contentSize
        _controlScrollView.showsVerticalScrollIndicator = false
        _controlScrollView.showsHorizontalScrollIndicator = false
        
        // The panGestureRecognizer is removed because pan gestures might be triggered
        // on subviews of the scrollview which do not ignore touch events (determined
        // by `viewIgnoresEvents(_ view: UIView?)`.
        removeGestureRecognizer(panGestureRecognizer)
    }
    
    func updateCustomScrollViewFrame() {
        if _controlScrollView.frame == frame { return }
        _controlScrollView.frame = frame
    }
}
