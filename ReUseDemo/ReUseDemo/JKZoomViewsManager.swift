
//Hello This is Jack!

import UIKit

/*
 * 实现图片（任意View）的放大查看。
 1.可以是约束布局的View，也可以是坐标(frame)布局的View
 2.注意，因为放大View的时候，需要将View从原来视图移除，所以结束查看hide()之后，默认会将View直接添加在其原来的superView的最上层！
 但是可以通过设置aboveView或者belowView(showView的兄弟视图)属性来控制showView在父视图中的层级。
 3.目前只实现了一次查看一张图片（View）。
 */

typealias jacksZoomManagerCallback = () -> Void
class JKZoomViewsManager: NSObject {
    //图片（视图缩放）
    
    static let zoomViewsManager = JKZoomViewsManager()
    
    class var sharedInstance: JKZoomViewsManager {
        zoomViewsManager.replaceView.backgroundColor = UIColor.clear
        zoomViewsManager.contentView.backgroundColor = UIColor.black
        return zoomViewsManager
    }
    
    //contentView将被添加到keyWindow中全屏展示。把需要显示的showView显示在其上
    private let contentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    private var showView: UIView?   //show(zoomView: UIView)传入的视图，即需要放大的视图
    private let replaceView = UIView()      //占位用的空白View（当superView对showView有约束时，移除showView之后，需要另一个视图填补其superView缺失的约束）
    private var savedConstraints: [NSLayoutConstraint]?
    private var isShowing: Bool = false
    private var lastOperationDate = Date(timeIntervalSinceNow: -2)
    private let lockInterval = 0.4  //防止一次操作未完成就进行另一次操作！(值越大，锁定时间越久，越安全。必须大于执行动画所需的0.25，且要考虑其他运算的时间、卡顿的时间等)
    
    var zoomOutStart: jacksZoomManagerCallback?
    var zoomOutEnd: jacksZoomManagerCallback?
    var aboveView: UIView? //如果有，则把showView添加到aboveView前面
    var belowView: UIView? //如果有，则把showView添加到belowView后面
    
    override init() {
        super.init()
        let tap = UITapGestureRecognizer(target: self, action: #selector(contentViewTap))
        contentView.addGestureRecognizer(tap)
    }
    
    func show(zoomView: UIView) {
        
        if showView != nil {
            return
        }
        
        if lastOperationDate.timeIntervalSinceNow > -lockInterval {
            return
        }
        
        if isShowing {
            return
        }else {
            isShowing = true
        }
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let superView = zoomView.superview else {
            return
        }
        
        if zoomOutStart != nil {
            zoomOutStart!()
        }
        
        showView = zoomView
        
        savedConstraints = superView.constraints
        
        replace(zView: zoomView)        //占位
        
        keyWindow.addSubview(contentView)
        contentView.isHidden = true
        
        var viewW = zoomView.bounds.size.width
        var viewH = zoomView.bounds.size.height
        
        let screenW = keyWindow.bounds.size.width
        let screenH = keyWindow.bounds.size.height
        
        var finalViewW: CGFloat = 0
        var finalViewH: CGFloat = 0
        
        if let imgView = showView as? UIImageView, let image = imgView.image {
            let imageSize = image.size
            viewW = imageSize.width
            viewH = imageSize.height
        }
        
        if viewW/viewH > screenW/screenH  {
            finalViewW = screenW
            finalViewH = viewH*finalViewW/viewW
        }else{
            finalViewH = screenH - 40.0 //status bar height * 2
            finalViewW = viewW*finalViewH/viewH
        }
        
        let finalX = (screenW - finalViewW)/2.0
        let finalY = (screenH - finalViewH)/2.0
        
        let orgFrame = superView.convert(zoomView.frame, to: keyWindow)//为了动画效果添加的额外代码（从'原始'位置放大！）
        contentView.addSubview(zoomView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {//必须有延时！！否则无法正确渲染。（约束会覆盖frame！）
            zoomView.frame = orgFrame//为了动画效果添加的额外代码（从'原始'位置放大！）
            self.contentView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                zoomView.frame = CGRect(x: finalX, y: finalY, width: finalViewW, height: finalViewH)
            })
        }
        
        lastOperationDate = Date()
    }
    
    func hide() {
        
        if lastOperationDate.timeIntervalSinceNow > -lockInterval {
            return
        }
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let zView = showView else {
            return
        }
        
        guard let superView = replaceView.superview else {
            return
        }
        
        /**********额外动画效果**********/
        let orgFrame = superView.convert(self.replaceView.frame, to: keyWindow)
        UIView.animate(withDuration: 0.2, animations: {
            zView.frame = orgFrame
        })
        /**********额外动画效果**********/
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {//动画结束后
            if let aboveView = self.aboveView , (self.replaceView.superview == aboveView.superview) {
                superView.insertSubview(zView, aboveSubview: aboveView)
            }else if let belowView = self.belowView , (self.replaceView.superview == belowView.superview) {
                superView.insertSubview(zView, belowSubview: belowView)
            }else {
                superView.addSubview(zView)
            }
            
            zView.frame = self.replaceView.frame
            
            for constraint in self.savedConstraints! {
                
                var isZoomViewConstraint = false
                if let first = constraint.firstItem, first.hash == zView.hash {
                    isZoomViewConstraint = true
                }else if let sencond = constraint.secondItem, sencond.hash == zView.hash {
                    isZoomViewConstraint = true
                }
                if !isZoomViewConstraint {
                    continue
                }
                
                if superView.constraints.contains(constraint) {
                    //不可能的事情！
                }else {
                    superView.addConstraint(constraint)
                }
            }
            
            self.replaceView.removeFromSuperview()
            self.contentView.removeFromSuperview()
            
            self.showView = nil
            self.aboveView = nil
            self.belowView = nil
            
            self.isShowing = false
            self.lastOperationDate = Date()
            
            if self.zoomOutEnd != nil {
                self.zoomOutEnd!()
            }
        }
    }
    
    //用一个空白View替换要放大的zView，保证zView父视图的约束没有被破坏！
    private func replace(zView: UIView) {
        guard let superView = zView.superview else {
            return
        }
        superView.addSubview(replaceView)
        
        //如果没有这句，非约束、纯frame的情况会崩溃（因为replaceView初始化为UIView()，没有frame；会导致1、hide()之后zoomView不能显示，2、第二次执行show()内的zoomView.frame = CGRect(x: finalX, y: finalY, width: finalViewW, height: finalViewH)会崩溃）
        replaceView.frame = zView.frame
        
        for constraint in savedConstraints! {
            
            var isZoomViewConstraint = false
            if let first = constraint.firstItem, first.hash == zView.hash {
                isZoomViewConstraint = true
            }else if let sencond = constraint.secondItem, sencond.hash == zView.hash {
                isZoomViewConstraint = true
            }
            if !isZoomViewConstraint {
                continue
            }
            
            var firstItem: Any!
            var secondItem: Any?
            
            if let first = constraint.firstItem, first.hash == zView.hash {
                firstItem = replaceView
                secondItem = constraint.secondItem
            }else if let sencond = constraint.secondItem, sencond.hash == zView.hash {
                firstItem = constraint.firstItem
                secondItem = replaceView
            }
            
            let cpConstraint = NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
            superView.addConstraint(cpConstraint)
        }
        
        let cWidth = NSLayoutConstraint(item: replaceView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: zView.frame.size.width)
        let cHeight = NSLayoutConstraint(item: replaceView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: zView.frame.size.height)
        
        replaceView.addConstraint(cWidth)
        replaceView.addConstraint(cHeight)
    }
    
    @objc private func contentViewTap() {
        hide()
    }
    
}


