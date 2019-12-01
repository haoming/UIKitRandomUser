//
//  LoadMoreControl.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 30/11/19.
//
//  revised version of the code from https://stackoverflow.com/a/44056792

import UIKit

protocol LoadMoreControlDelegate: class {
    func loadMoreControl(didStartAnimating loadMoreControl: LoadMoreControl)
    func loadMoreControl(didStopAnimating loadMoreControl: LoadMoreControl)
}

class LoadMoreControl {

    private let spacingFromLastCell: CGFloat
    private let indicatorHeight: CGFloat
    private weak var activityIndicatorView: UIActivityIndicatorView?
    private weak var scrollView: UIScrollView?
    weak var delegate: LoadMoreControlDelegate?
    
    var enabled = true

    private var defaultY: CGFloat {
        guard let height = scrollView?.contentSize.height else {
            return 0.0
        }
        return height + spacingFromLastCell
    }

    init(scrollView: UIScrollView, spacingFromLastCell: CGFloat, indicatorHeight: CGFloat) {
        self.scrollView = scrollView
        self.spacingFromLastCell = spacingFromLastCell
        self.indicatorHeight = indicatorHeight

        let size:CGFloat = 40
        let frame = CGRect(x: (scrollView.frame.width-size)/2, y: scrollView.contentSize.height + spacingFromLastCell, width: size, height: size)
        let activityIndicatorView = UIActivityIndicatorView(frame: frame)
        activityIndicatorView.hidesWhenStopped = true
        if #available(iOS 13, *) {
            activityIndicatorView.color = .label // support both light mode and dark mode
        } else {
            activityIndicatorView.color = .darkGray
        }
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        scrollView.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true
        self.activityIndicatorView = activityIndicatorView
    }

    private var isHidden: Bool {
        guard let scrollView = scrollView else { return true }
        return scrollView.contentSize.height < scrollView.frame.size.height
    }

    func didScroll() {
        guard self.enabled else {
            return
        }
        guard let scrollView = scrollView, let activityIndicatorView = activityIndicatorView else { return }
        let offsetY = scrollView.contentOffset.y
        activityIndicatorView.isHidden = isHidden
        if !activityIndicatorView.isHidden && offsetY >= 0 {
            let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
            let offsetDelta = offsetY - contentDelta

            let newY = defaultY-offsetDelta
            if newY < scrollView.frame.height {
                activityIndicatorView.frame.origin.y = newY
            } else {
                if activityIndicatorView.frame.origin.y != defaultY {
                    activityIndicatorView.frame.origin.y = defaultY
                }
            }

            if !activityIndicatorView.isAnimating {
                if offsetY > contentDelta && offsetDelta >= indicatorHeight && !activityIndicatorView.isAnimating {
                    activityIndicatorView.startAnimating()
                    delegate?.loadMoreControl(didStartAnimating: self)
                }
            }
        }
    }

    func stop() {
        endAnimating()
    }

    private func endAnimating() {
        activityIndicatorView?.stopAnimating()
        delegate?.loadMoreControl(didStopAnimating: self)
    }
}
