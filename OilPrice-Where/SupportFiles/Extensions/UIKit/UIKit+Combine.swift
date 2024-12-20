//
//  Combine+UIKit.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/05.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine


extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        controlPublisher(for: .editingChanged)
            .compactMap { $0 as? UITextField }
            .map { $0.text }
            .eraseToAnyPublisher()
    }
    
    var attributedTextPublisher: AnyPublisher<NSAttributedString?, Never> {
        controlPublisher(for: .editingChanged)
            .compactMap { $0 as? UITextField }
            .map { $0.attributedText }
            .eraseToAnyPublisher()
    }

    var returnPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .editingDidEndOnExit)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    var didBeginEditingPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .editingDidBegin)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var didEndEditingPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .editingDidEnd)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var touchDownPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .touchDown)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

extension UISegmentedControl {
    var selectedSegmentIndexPublisher: AnyPublisher<Int, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISegmentedControl }
            .map { $0.selectedSegmentIndex }
            .eraseToAnyPublisher()
    }
}

extension UISlider {
    var valuePublisher: AnyPublisher<Float, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISlider }
            .map { $0.value }
            .eraseToAnyPublisher()
    }
}

extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .touchUpInside)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

extension UISwitch {
    var isOnPublisher: AnyPublisher<Bool, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISwitch }
            .map { $0.isOn }
            .eraseToAnyPublisher()
    }
}

extension UIStepper {
    var valuePublisher: AnyPublisher<Double, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UIStepper }
            .map { $0.value }
            .eraseToAnyPublisher()
    }
}

extension UIDatePicker {
    var datePublisher: AnyPublisher<Date, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UIDatePicker }
            .map { $0.date }
            .eraseToAnyPublisher()
    }
    
    var countDownDurationPublisher: AnyPublisher<TimeInterval, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UIDatePicker }
            .map { $0.countDownDuration }
            .eraseToAnyPublisher()
    }
}

extension UIRefreshControl {
    var isRefreshingPublisher: AnyPublisher<Bool, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UIRefreshControl }
            .map { $0.isRefreshing }
            .eraseToAnyPublisher()
    }
}

extension UIPageControl {
    var currentPagePublisher: AnyPublisher<Int, Never> {
        publisher(for: \.currentPage)
            .eraseToAnyPublisher()
    }
}

extension UIScrollView {
    var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        publisher(for: \.contentOffset)
            .eraseToAnyPublisher()
    }
    
    /// UIScrollView 맨 아래에 도달한 경우
    func reachedBottomPublisher(offset: CGFloat = 0) -> AnyPublisher<Void, Never> {
        contentOffsetPublisher
            .map { [weak self] contentOffset -> Bool in
                guard let self = self else { return false }
                let visibleHeight = self.frame.height - self.contentInset.top - self.contentInset.bottom
                let yDelta = contentOffset.y + self.contentInset.top
                let threshold = max(offset, self.contentSize.height - visibleHeight)
                return yDelta > threshold
            }
            .removeDuplicates()
            .filter { $0 }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

