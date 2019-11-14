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

public class UIAdaptivePresentationControllerDelegateProxy: DelegateProxy<UIPresentationController, UIAdaptivePresentationControllerDelegate>, UIAdaptivePresentationControllerDelegate, DelegateProxyType {
    
    public weak var viewController: UIPresentationController?
    
    init(viewController: UIPresentationController) {
        self.viewController = viewController
        super.init(parentObject: viewController, delegateProxy: UIAdaptivePresentationControllerDelegateProxy.self)
    }
    
    public static func currentDelegate(for object: UIPresentationController) -> UIAdaptivePresentationControllerDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UIAdaptivePresentationControllerDelegate?, to object: UIPresentationController) {
        object.delegate = delegate
    }
    
    public static func registerKnownImplementations() {
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
    
    /// Called on the delegate when the user has taken action to dismiss the presentation, before interaction or animations begin.
    /// 
    /// Use this callback to setup alongside animations or interaction notifications with the presentingViewController's transitionCoordinator.
    /// This is not called if the presentation is dismissed programatically.
    @available(iOS 13.0, *)
    public var willDismiss: Observable<Void> {
        let source = rx_delegate.methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerWillDismiss(_:))).map { result -> Void in
            return result[1] as! Void
        }
        return source
    }
    
    /// Called on the delegate when the user has taken action to dismiss the presentation successfully, after all animations are finished.
    ///
    /// This is not called if the presentation is dismissed programatically.
    @available(iOS 13.0, *)
    public var didDismiss: Observable<Void> {
        let source = rx_delegate.methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss(_:))).map { result -> Void in
            return result[1] as! Void
        }
        return source
    }
}
