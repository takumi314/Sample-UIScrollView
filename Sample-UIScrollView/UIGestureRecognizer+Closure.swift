//
//  UIGestureRecognizer+Closure.swift
//  Sample-UIScrollView
//
//  Created by NishiokaKohei on 2018/04/14.
//  Copyright © 2018年 Kohey. All rights reserved.
//

import UIKit

extension UIGestureRecognizer {

    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    convenience init(target: Any? = nil, _ closure: @escaping (UIGestureRecognizer) -> Void) {
        self.init(target: target, action: #selector(closureMethod))
        let selector = ClosureSelector<UIGestureRecognizer>(with: closure)
        objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, selector, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    @objc private func closureMethod() {
        guard let selector = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureSelector<UIGestureRecognizer>
            else { return }
        selector.target(self)
    }

}


///
/// Parameter T: the type of parameter passed in the selector
///
private class ClosureSelector<T> {

    public let selector: Selector

    fileprivate let closure: (T) -> ()

    init(with closure: @escaping (T) -> Void) {
        self.selector = #selector(ClosureSelector<T>.target(_:))
        self.closure = closure
    }

    @objc fileprivate func target(_ parameter: Any) {
        closure(parameter as! T)
    }
}

