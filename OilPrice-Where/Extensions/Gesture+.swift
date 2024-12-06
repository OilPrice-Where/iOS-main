//
//  Gesture+.swift
//  OilPrice-Where
//
//  Created by wargi on 2023/03/11.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import UIKit
import Combine

/*
 * MARK: GesturePulisher
 */

public enum GestureType {
    case tap
    case longpress
    case pan
    case pinch
    case swipe
    case edge
    
    public var gesture: UIGestureRecognizer {
        switch self {
        case .tap:
            return UITapGestureRecognizer()
        case .longpress:
            return UILongPressGestureRecognizer()
        case .pan:
            return UIPanGestureRecognizer()
        case .pinch:
            return UIPinchGestureRecognizer()
        case .swipe:
            return UISwipeGestureRecognizer()
        case .edge:
            return UIScreenEdgePanGestureRecognizer()
        }
    }
}

public extension UIView {
    /// GesturePublisher
    func gesturePublisher(_ gestureType: GestureType = .tap,
                          delegate: UIGestureRecognizerDelegate? = nil) -> AnyPublisher<UIGestureRecognizer, Never> {
        let gesture = gestureType.gesture
        gesture.delegate = delegate
        return GesturePublisher(targetView: self, gesture: gesture).eraseToAnyPublisher()
    }

    // MARK: - Publisher
    struct GesturePublisher: Publisher {
        
        public typealias Output = UIGestureRecognizer
        
        public typealias Failure = Never
        
        private weak var targetView: UIView?
        
        private let gesture: UIGestureRecognizer
        
        public init(targetView view: UIView, gesture: UIGestureRecognizer) {
            self.targetView = view
            self.gesture = gesture
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == GesturePublisher.Failure, S.Input == GesturePublisher.Output {
            let subscription = GestureSubscription(subscriber: subscriber,
                                                   targetView: targetView,
                                                   gesture: gesture)
            
            subscriber.receive(subscription: subscription)
        }
    }

    // MARK: - Subscription
    private final class GestureSubscription<S: Subscriber>: Subscription where S.Input == UIGestureRecognizer, S.Failure == Never {
        private var subscriber: S?
        private var gesture: UIGestureRecognizer
        private weak var targetView: UIView?
        
        init(subscriber: S, targetView view: UIView?, gesture: UIGestureRecognizer) {
            self.subscriber = subscriber
            self.targetView = view
            self.gesture = gesture
            
            view?.isUserInteractionEnabled = true
            
            gesture.addTarget(self, action: #selector(gestureHandler))
            view?.addGestureRecognizer(gesture)
        }
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        func cancel() {
            subscriber = nil
            targetView?.isUserInteractionEnabled = false
            gesture.removeTarget(self, action: #selector(gestureHandler))
        }
        
        @objc
        private func gestureHandler() {
            _ = subscriber?.receive(gesture)
        }
    }
}
