//
//  UIAdaptivePresentationControllerDelegateProxy.swift
//  RxAppState
//
//  Created by Steve Dao on 14/11/19.
//  Copyright © 2019 RxAppState. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class UIAdaptivePresentationControllerDelegateProxy: DelegateProxy<UIPresentationController, UIAdaptivePresentationControllerDelegate>, UIAdaptivePresentationControllerDelegate, DelegateProxyType {
    
    public weak var viewController: UIPresentationController?
    
    init(viewController: UIPresentationController) {
        self.viewController = viewController
        super.init(parentObject: viewController, delegateProxy: UIAdaptivePresentationControllerDelegateProxy.self)
    }
    
    static func currentDelegate(for object: UIPresentationController) -> UIAdaptivePresentationControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: UIAdaptivePresentationControllerDelegate?, to object: UIPresentationController) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { UIAdaptivePresentationControllerDelegateProxy(viewController: $0) }
    }
}

extension UIPresentationController: HasDelegate {
    public typealias Delegate = UIAdaptivePresentationControllerDelegate
}

extension Reactive where Base: UIPresentationController {
    public var rx_delegate: DelegateProxy<UIPresentationController, UIAdaptivePresentationControllerDelegate> {
        return UIAdaptivePresentationControllerDelegateProxy.proxy(for: base)
    }
    
    public var presentationControllerDidDismiss: Observable<Void> {
        if #available(iOS 13.0, *) {
            let source = rx_delegate.methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss(_:))).map { result -> Void in
                return result[1] as! Void
            }
            return source
        } else {
            // Fallback on earlier versions
            return ControlEvent<Void>.empty()
        }
    }
}
