//
//  UIControl.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit
import Combine


/*
 * MARK: Combine 이벤트 pulisher 별도 구현
 */
public extension UIControl {
    func controlPublisher(for event: UIControl.Event) -> ControlPublisher {
        return ControlPublisher(control: self, event: event)
    }
    
    final class ControlSubscription<SubscriberType: Subscriber>: Subscription where SubscriberType.Input == ControlPublisher.Output, SubscriberType.Failure == ControlPublisher.Failure {
        
        private let control: UIControl
        private let event: UIControl.Event
        private var subscriber: SubscriberType?
        
        init(subscriber: SubscriberType, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            control.addTarget(self, action: #selector(handle), for: event)
        }
                    
        public func request(_ demand: Subscribers.Demand) {
            // 해당 메소드에서는 별도로 구현체가 필요없다
        }
        
        public func cancel() {
            subscriber = nil
            control.removeTarget(self, action: #selector(handle), for: event)
        }
        
        @objc func handle(_ sender: UIControl) {
            _ = self.subscriber?.receive(control)
        }
    }
    
    struct ControlPublisher: Publisher {

        public typealias Output = UIControl
        
        public typealias Failure = Never

        private let control: UIControl
        
        private let event: UIControl.Event

        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        public func receive<SubscriberType>(subscriber: SubscriberType) where SubscriberType: Subscriber, SubscriberType.Failure == ControlPublisher.Failure, SubscriberType.Input == ControlPublisher.Output {
            let subscription = ControlSubscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }
    }
}
