//
//  YCPopViewCreator.swift
//  Demo
//
//  Created by xiaoyuan on 2017/6/17.
//  Copyright © 2017年 YC. All rights reserved.
//

import Foundation

public enum PopPosition {
    case center(style:PopCerterStyle)
    case bottom(style:PopStyle)
    case top(style:PopStyle)
    case left(style:PopStyle)
    case right(style:PopStyle)
}

public enum PopStyle {
    case fade(alignment:ViewAlignment)
    case moveIn(bounce:Bool,alignment:ViewAlignment)
}

public enum PopCerterStyle: Int {
    case fade = 1
    case pop
    case fromTop
    case fromBottom
    case fromLeft
    case fromRight
}

public enum ViewAlignment {
    case original
    case left
    case center
    case right
}

protocol PopCreator {
    func show(style: PopPosition)
    func dismiss()
}

/// Abstract class
public class BasicPopViewCreator: PopCreator {
    
    public var touchBackDismiss = true
    
    public var animationDuration: TimeInterval = 0.4
    public var initialSpringVelocity: CGFloat = 8
    public var dampingRatio: CGFloat = 0.5
    
    public var targetView: UIView!
    public var showInView: UIView!
    
    public lazy var backView: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        return btn
    }()
    
    public lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(self.backView)
        return view
    }()
    
    public init() { }
    
    public func show(style: PopPosition) {
        assertionFailure("implement by subclass")
    }
    
    public func dismiss() {
        assertionFailure("implement by subclass")
    }
    
    @objc public func clickBack() {
        if touchBackDismiss {
            dismiss()
        }
    }
}

public final class YCPopViewCreator: BasicPopViewCreator {
    
    fileprivate var style: PopPosition?
    
    public override func show(style: PopPosition) {
        containerView.frame = showInView.bounds
        backView.frame = showInView.bounds
        containerView.addSubview(targetView)
        showInView.addSubview(containerView)
        self.style = style
        
        switch style {
        case .center(let st):
            switch st {
                case .fade:
                    targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.midY)
                    fadeShow()
                case .pop:
                    targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.midY)
                    containerView.alpha = 0
                    targetView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    
                    fadeShow(block: { 
                        self.targetView.transform = .identity
                    })
                case .fromTop:
                    backView.alpha = 0
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: -targetView.bounds.height / 2)
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                        self.targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.midY)
                        self.backView.alpha = 1
                    }, completion: nil)
                case .fromLeft:
                    backView.alpha = 0
                    targetView.center = CGPoint(x: -targetView.bounds.maxX / 2, y: showInView.bounds.midY)
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                        self.targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.midY)
                        self.backView.alpha = 1
                    }, completion: nil)
                case .fromRight:
                    backView.alpha = 0
                    targetView.center = CGPoint(x: showInView.bounds.maxX+targetView.bounds.maxX/2, y: showInView.bounds.midY)
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                        self.targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.midY)
                        self.backView.alpha = 1
                    }, completion: nil)
                case .fromBottom:
                    backView.alpha = 0
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.maxY+targetView.bounds.height/2)
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                        self.targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.midY)
                        self.backView.alpha = 1
                    }, completion: nil)
            }
        case .bottom(let st):
            switch st {
            case .fade(let alignment):
                switch alignment {
                case .left:
                    targetView.frame.origin.x = 0
                case .center:
                    targetView.frame.origin.x = showInView.bounds.midX - targetView.frame.width/2
                case .right:
                    targetView.frame.origin.x = showInView.bounds.maxX - targetView.frame.width
                default: break
                }
                targetView.frame.origin.y = showInView.bounds.height - targetView.frame.height
                fadeShow()
            case .moveIn(let bounce,let alignment):
                backView.alpha = 0
                
                switch alignment {
                    case .left:
                        targetView.frame.origin.x = 0
                    case .center:
                        targetView.frame.origin.x = showInView.bounds.midX - targetView.frame.width/2
                    case .right:
                        targetView.frame.origin.x = showInView.bounds.maxX - targetView.frame.width
                    default: break
                }
                targetView.frame.origin.y = showInView.bounds.height
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    self.targetView.frame.origin.y = self.showInView.bounds.height - self.targetView.frame.height
                    self.backView.alpha = 1
                }, completion: nil)
            }
        case .left(let st):
            switch st {
            case .fade(let alignment):
                switch alignment {
                case .left:
                    targetView.frame.origin.y = 0
                case .center:
                    targetView.frame.origin.y = showInView.bounds.midY - targetView.frame.height/2
                case .right:
                    targetView.frame.origin.y = showInView.bounds.maxY - targetView.frame.width
                default: break
                }
                targetView.frame.origin.x = 0
                fadeShow()
            case .moveIn(let bounce,let alignment):
                backView.alpha = 0
                
                switch alignment {
                case .left:
                    targetView.frame.origin.y = 0
                case .center:
                    targetView.frame.origin.y = showInView.bounds.midY - targetView.frame.height/2
                case .right:
                    targetView.frame.origin.y = showInView.bounds.maxY - targetView.frame.width
                default: break
                }
                targetView.frame.origin.x = -targetView.bounds.width
                
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    self.targetView.frame.origin.x = 0
                    self.backView.alpha = 1
                }, completion: nil)
            }
        case .top(let st):
            switch st {
            case .fade(let alignment):
                switch alignment {
                case .left:
                    targetView.frame.origin.x = 0
                case .center:
                    targetView.frame.origin.x = showInView.bounds.midX - targetView.frame.width/2
                case .right:
                    targetView.frame.origin.x = showInView.bounds.maxX - targetView.frame.width
                default: break
                }
                targetView.frame.origin.y = 0
                fadeShow()
            case .moveIn(let bounce,let alignment):
                backView.alpha = 0
                switch alignment {
                case .left:
                    targetView.frame.origin.x = 0
                case .center:
                    targetView.frame.origin.x = showInView.bounds.midX - targetView.frame.width/2
                case .right:
                    targetView.frame.origin.x = showInView.bounds.maxX - targetView.frame.width
                default: break
                }
                targetView.frame.origin.y = -showInView.bounds.height
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    self.targetView.frame.origin.y = 0
                    self.backView.alpha = 1
                }, completion: nil)
            }
        case .right(let st):
            switch st {
            case .fade(let alignment):
                switch alignment {
                case .left:
                    targetView.frame.origin.y = 0
                case .center:
                    targetView.frame.origin.y = showInView.bounds.midY - targetView.frame.height/2
                case .right:
                    targetView.frame.origin.y = showInView.bounds.maxY - targetView.frame.width
                default: break
                }
                targetView.frame.origin.x = showInView.bounds.width - targetView.frame.width
                fadeShow()
            case .moveIn(let bounce,let alignment):
                backView.alpha = 0
                
                switch alignment {
                case .left:
                    targetView.frame.origin.y = 0
                case .center:
                    targetView.frame.origin.y = showInView.bounds.midY - targetView.frame.height/2
                case .right:
                    targetView.frame.origin.y = showInView.bounds.maxY - targetView.frame.width
                default: break
                }
                targetView.frame.origin.x = showInView.bounds.width
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    self.targetView.frame.origin.x = self.showInView.bounds.width - self.targetView.frame.width
                    self.backView.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    public override func dismiss() {
        guard let style = style else { return }
        switch style {
        case .center(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .pop:
                fadeDismiss(block: { 
                    self.targetView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                })
            case .fromTop:
                moveInDismiss(bounce: true, block: {
                    self.targetView.center = CGPoint(x: self.showInView.bounds.midX, y: self.showInView.bounds.maxY+self.targetView.bounds.height/2)
                })
            case .fromLeft:
                moveInDismiss(bounce: true, block: {
                    self.targetView.center = CGPoint(x: self.showInView.bounds.maxX+self.targetView.bounds.maxX/2, y: self.showInView.bounds.midY)
                })
            case .fromRight:
                moveInDismiss(bounce: true, block: {
                    self.targetView.center = CGPoint(x: -self.targetView.bounds.maxX/2, y: self.showInView.bounds.midY)
                })
            case .fromBottom:
                moveInDismiss(bounce: true, block: {
                    self.targetView.center = CGPoint(x: self.showInView.bounds.midX, y: -self.targetView.bounds.height/2)
                })
            }
        case .bottom(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    self.targetView.frame.origin.y = self.showInView.bounds.height
                })
            }
        case .top(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    self.targetView.frame.origin.y = -self.targetView.bounds.height
                })
            }
        case .right(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    self.targetView.frame.origin.x = self.showInView.bounds.width
                })
            }
            
        case .left(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: { 
                    self.targetView.frame.origin.x = -self.targetView.frame.width
                })
            }
        }
    }
    
    private func fadeShow(block: (() -> Void)? = nil) {
        containerView.alpha = 0
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
            self.containerView.alpha = 1
            block?()
        }, completion: nil)
    }
    
    private func fadeDismiss(block: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
            self.containerView.alpha = 0
            block?()
        }, completion: { _ in
            self.containerView.alpha = 1
            self.targetView.removeFromSuperview()
            self.containerView.removeFromSuperview()
        })
    }
    
    private func moveInDismiss(bounce: Bool, block: @escaping () -> Void) {
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
            self.backView.alpha = 0
            block()
        }, completion: { _ in
            self.backView.alpha = 1
            self.targetView.removeFromSuperview()
            self.containerView.removeFromSuperview()
        })
    }
    
}


public protocol PopAble {
    
}

var popCreatorKey = ""

extension PopAble where Self: UIView {
    
    /// 创建popview的创建器,默认为YCPopViewCreator
    public var popCreator: BasicPopViewCreator! {
        set {
            objc_setAssociatedObject(self, &popCreatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            var pop = objc_getAssociatedObject(self, &popCreatorKey) as? BasicPopViewCreator
            if pop == nil {
                pop = YCPopViewCreator()
                objc_setAssociatedObject(self, &popCreatorKey, pop, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return pop
        }
    }
    
    /// 显示pop view
    /// - Parameters:
    ///     - view: 父容器
    ///     - posistion: 位置
    public func show(`in` view: UIView, posistion: PopPosition = .center(style: .pop))  {
        popCreator.showInView = view
        popCreator.targetView = self
        popCreator.show(style: posistion)
    }
    
    /// 隐藏pop view
    public func dismiss() {
        popCreator.dismiss()
    }
    
}

