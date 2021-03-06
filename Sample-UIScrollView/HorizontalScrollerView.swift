//
//  HorizontalScrollerView.swift
//  Sample-UIScrollView
//
//  Created by NishiokaKohei on 2018/04/10.
//  Copyright © 2018年 Kohey. All rights reserved.
//

import UIKit

public enum ScrollDirection {
    case vertical
    case horizontal
}

public protocol HorizontalScrollerViewDataSource {
    func numberOfViewa(in horizontalScrollerView: HorizontalScrollerView) -> Int
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView
}

public protocol HorizontalScrollerViewDelegate {
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int)
}

open class HorizontalScrollerView: UIView {

    // MARK: - Public properties

    open var dataSource: HorizontalScrollerViewDataSource? {
        didSet {
            guard let _ = dataSource else {
                return
            }
            self.reload()
        }
    }

    open var delagate: HorizontalScrollerViewDelegate?

    open var direction: ScrollDirection = .horizontal

    // MARK: - Private properties

    private var scroller = UIScrollView()
    private var pageControl = UIPageControl()
    private var contentViews = [UIView]()
    private var canvasSize = CGSize(width: Controllers.Dimensions, height: Controllers.Dimensions)

    private var imageSize: (height: CGFloat, width: CGFloat) = ( 1.0, 1.0)

    // 縦横比  横 : 縦 = 1 : radio
    private var radio: CGFloat {
        return imageSize.height / imageSize.width
    }

    // default
    private enum Controllers {
        static let Padding: CGFloat = 0.0
        
        static let Dimensions: CGFloat = 100

        static let Offset: CGFloat = 10
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        initializeScrollView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    public func sizeToFitWidth() {

    }

    public func sizeToFitHeight() {

    }

    public func reload() {
        guard let dataSource = self.dataSource
            else { return }

        contentViews.forEach({ $0.removeFromSuperview() })

        var xValue: CGFloat = 0.0

        let content = dataSource.horizontalScrollerView(self, viewAt: 0)

        // 描画する各コンテンツのサイズを設定する
        canvasSize.width = self.bounds.width - 2 * Controllers.Padding
        canvasSize.height = canvasSize.width * content.bounds.height / content.bounds.width - 2 * Controllers.Padding

        let numberOfPages = dataSource.numberOfViewa(in: self)

        // ページ数
        pageControl.numberOfPages = numberOfPages
        pageControl.updateCurrentPageDisplay()

        contentViews = (0 ..< numberOfPages).map {
            (index: Int) -> UIView in

            // 左から順にコンテンツを配置する
            xValue += Controllers.Padding
            let contentView = dataSource.horizontalScrollerView(self, viewAt: index)
            contentView.frame = CGRect(x: xValue,
                                       y: Controllers.Padding,
                                       width: canvasSize.width,
                                       height: canvasSize.height)

            xValue += canvasSize.width + Controllers.Padding

            return contentView
        }

        contentViews.forEach({ scroller.addSubview($0) })

        scroller.contentSize = CGSize(width: xValue, height: frame.size.height)
        scroller.insertSubview(pageControl, aboveSubview: contentViews.last!)

        pageControl.hidesForSinglePage = true
        pageControl.updateCurrentPageDisplay()
    }


    // MARK: - Private methods

    private func initializeScrollView() {
        reload()

        self.addSubview(scroller)
        scroller.isPagingEnabled = true
        scroller.frame = self.bounds

        NSLayoutConstraint.activate([
            scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scroller.topAnchor.constraint(equalTo: self.topAnchor),
            scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        updateTapGesture()
        scroller.delegate = self

        initilizePageControl()
    }

    private func updateTapGesture() {
        scroller.removeGestureRecognizer(UIGestureRecognizer())
        let tap = UITapGestureRecognizer { [unowned self](gesture) in
            // action after tapping
            let location = gesture.location(in: self.scroller)
            if let index = self.indexOfViewTapped(at: location) {
                // index 画像を正面に移動する
            }
        }
        scroller.addGestureRecognizer(tap)
    }

    private func indexOfViewTapped(at location: CGPoint) -> Int? {
        guard let view = viewTapped(at: location) else { return nil }
        return contentViews.index(where: { $0 == view })
    }

    private func viewTapped(at location: CGPoint) -> UIView? {
        return contentViews.filter({ $0.frame.contains(location) }).first
    }

    private func initilizePageControl() {
        pageControl.center.x = scroller.center.x
        pageControl.center.y = scroller.center.y + scroller.bounds.size.height / 2.0 + 30.0
        pageControl.bounds.size = CGSize(width: canvasSize.width, height: 30)
        pageControl.isHidden = false
        pageControl.tintColor = .blue
        pageControl.currentPage = 0
        scroller.addSubview(pageControl)
    }

}

    // MARK: - UIScrollViewDelegate

extension HorizontalScrollerView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            pageControl.currentPage = page(on: scrollView)
            pageControl.updateCurrentPageDisplay()
        }
    }

    // MARK: - Private method

    private func page(on scrollView: UIScrollView) -> Int {
        let page = (scrollView.contentOffset.x + 1.0) / scrollView.bounds.width
        return Int(page)
    }

}


