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

public protocol PopCreator {
    func show(style: PopPosition)
    func dismiss()
}

/// Abstract class
open class BasicPopViewCreator: PopCreator {
    
    public var touchBackDismiss = true
    
    public var animationDuration: TimeInterval = 0.4
    public var initialSpringVelocity: CGFloat = 6
    public var dampingRatio: CGFloat = 0.7
    
    public weak var targetView: UIView?
    public weak var showInView: UIView?
    
    public var complement: (()->())?
    
    ///可通过设置其背景色来修改整体背景，默认是无色
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
    
    open func show(style: PopPosition) {
        assertionFailure("implement by subclass")
    }
    
    open func dismiss() {
        assertionFailure("implement by subclass")
    }
    
    @objc open func clickBack() {
        if touchBackDismiss {
            dismiss()
        }
    }
}

public final class YCPopViewCreator: BasicPopViewCreator {
    
    fileprivate var style: PopPosition?
    
    public override weak var targetView: UIView? {
        didSet {
            extensionView.backgroundColor = targetView?.backgroundColor
            containerView.addSubview(extensionView)
        }
    }
    
    ///添加额外的拓展区域的，避免弹性动画时断层
    fileprivate var extensionWidth: CGFloat = 40.0 {
        didSet {
            if extensionWidth == 0 {
                extensionView.isHidden = true
            } else {
                extensionView.isHidden = false
            }
        }
    }
    
    fileprivate lazy var extensionView: UIView = {
        let view = UIView()
        return view
    }()
    
    public override func show(style: PopPosition) {
        
        guard let targetView = targetView, let showInView = showInView else {
            return
        }
        
        containerView.frame = showInView.bounds
        backView.frame = showInView.bounds
        containerView.addSubview(targetView)
        showInView.addSubview(containerView)
        self.style = style
        
        switch style {
        case .center(let st):
            extensionView.frame = CGRect.zero
            switch st {
            case .fade:
                targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.midY)
                fadeShow()
            case .pop:
                targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.midY)
                containerView.alpha = 0
                targetView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                
                fadeShow(block: {
                    targetView.transform = .identity
                })
            case .fromTop:
                backView.alpha = 0
                targetView.center = CGPoint(x: showInView.bounds.midX, y: -targetView.bounds.height / 2)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.midY)
                    self.backView.alpha = 1
                }, completion: nil)
            case .fromLeft:
                backView.alpha = 0
                targetView.center = CGPoint(x: -targetView.bounds.maxX / 2, y: showInView.bounds.midY)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.midY)
                    self.backView.alpha = 1
                }, completion: nil)
            case .fromRight:
                backView.alpha = 0
                targetView.center = CGPoint(x: showInView.bounds.maxX+targetView.bounds.maxX/2, y: showInView.bounds.midY)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.midY)
                    self.backView.alpha = 1
                }, completion: nil)
            case .fromBottom:
                backView.alpha = 0
                targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.maxY+targetView.bounds.height/2)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.midY)
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
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetView.bounds.width, height: targetView.bounds.height + extensionWidth)
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
                var targetRect = targetView.frame
                targetRect.origin.y = showInView.bounds.height - targetView.frame.height
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetRect.width, height: targetRect.height + extensionWidth)
                
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.frame = targetRect
                    self.backView.alpha = 1
                }, completion: nil)
            }
        case .left(let st):
            extensionView.frame = CGRect(x: -extensionWidth, y: 0, width: targetView.bounds.width + extensionWidth, height: targetView.bounds.height)
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
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetView.bounds.width, height: targetView.bounds.height + extensionWidth)
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
                var targetRect = targetView.frame
                targetRect.origin.x = 0
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetRect.width, height: targetRect.height + extensionWidth)
                
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.frame = targetRect
                    self.backView.alpha = 1
                }, completion: nil)
            }
        case .top(let st):
            extensionView.frame = CGRect(x: 0, y: -extensionWidth, width: targetView.bounds.width, height: targetView.bounds.height + extensionWidth)
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
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetView.bounds.width, height: targetView.bounds.height + extensionWidth)
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
                var targetRect = targetView.frame
                targetRect.origin.y = 0
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetRect.width, height: targetRect.height + extensionWidth)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.frame = targetRect
                    self.backView.alpha = 1
                }, completion: nil)
            }
        case .right(let st):
            extensionView.frame = CGRect(x: 0, y: 0, width: targetView.bounds.width + extensionWidth, height: targetView.bounds.height)
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
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetView.bounds.width, height: targetView.bounds.height + extensionWidth)
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
                var targetRect = targetView.frame
                targetRect.origin.x = showInView.bounds.width - targetView.frame.width
                extensionView.frame = CGRect(x: targetView.frame.origin.x, y: targetView.frame.origin.y, width: targetRect.width, height: targetRect.height + extensionWidth)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
                    targetView.frame = targetRect
                    self.backView.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    public override func dismiss() {
        guard let style = style, let targetView = targetView, let showInView = showInView else { return }
        
        switch style {
        case .center(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .pop:
                fadeDismiss(block: {
                    targetView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                })
            case .fromTop:
                moveInDismiss(bounce: true, block: {
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: showInView.bounds.maxY+targetView.bounds.height/2)
                })
            case .fromLeft:
                moveInDismiss(bounce: true, block: {
                    targetView.center = CGPoint(x: showInView.bounds.maxX+targetView.bounds.maxX/2, y: showInView.bounds.midY)
                })
            case .fromRight:
                moveInDismiss(bounce: true, block: {
                    targetView.center = CGPoint(x: -targetView.bounds.maxX/2, y: showInView.bounds.midY)
                })
            case .fromBottom:
                moveInDismiss(bounce: true, block: {
                    targetView.center = CGPoint(x: showInView.bounds.midX, y: -targetView.bounds.height/2)
                })
            }
        case .bottom(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    targetView.frame.origin.y = showInView.bounds.height
                })
            }
        case .top(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    targetView.frame.origin.y = -targetView.bounds.height
                })
            }
        case .right(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    targetView.frame.origin.x = showInView.bounds.width
                })
            }
            
        case .left(let st):
            switch st {
            case .fade:
                fadeDismiss()
            case .moveIn(let bounce, _):
                moveInDismiss(bounce: bounce, block: {
                    targetView.frame.origin.x = -targetView.frame.width
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
            self.containerView.removeFromSuperview()
            self.targetView?.removeFromSuperview()
            self.complement?()
        })
    }
    
    private func moveInDismiss(bounce: Bool, block: @escaping () -> Void) {
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: bounce ?dampingRatio : 1, initialSpringVelocity: initialSpringVelocity, options: [], animations: {
            self.backView.alpha = 0
            block()
        }, completion: { _ in
            self.backView.alpha = 1
            self.targetView?.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.complement?()
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
    public func show(`in` view: UIView, posistion: PopPosition = .center(style: .pop), complement:(()->())? = nil)  {
        popCreator.showInView = view
        popCreator.targetView = self
        popCreator.complement = complement
        popCreator.show(style: posistion)
    }
    
    /// 隐藏pop view
    public func dismiss() {
        popCreator.dismiss()
    }
    
}

