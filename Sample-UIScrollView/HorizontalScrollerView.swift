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

    // 最新のOffsetを保持する
    private var lastScrollerOffset = CGPoint(x: 0.0, y: 0.0)

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

        let firstContent = dataSource.horizontalScrollerView(self, viewAt: 0)

        // 描画する各コンテンツのサイズを設定する
        canvasSize.width = self.bounds.width - 2 * Controllers.Padding
        canvasSize.height = canvasSize.width * firstContent.bounds.height / firstContent.bounds.width - 2 * Controllers.Padding

        let numberOfPages = dataSource.numberOfViewa(in: self)

        // ページ数
        pageControl.numberOfPages = numberOfPages
        pageControl.updateCurrentPageDisplay()

        var contents = (0 ..< numberOfPages).map {
            return dataSource.horizontalScrollerView(self, viewAt: $0)
        }

        // おまじない
        let content = contents.last!
        contents.removeLast()
        contents.insert(content, at: 0)

        var xValue: CGFloat = 0.0

        self.contentViews = (0 ..< numberOfPages).map {
            (index: Int) -> UIView in

            // 左から順にコンテンツを配置する
            xValue += Controllers.Padding
            let contentView = contents[index]
            contentView.frame = CGRect(x: xValue,
                                       y: Controllers.Padding,
                                       width: canvasSize.width,
                                       height: canvasSize.height)

            xValue += canvasSize.width + Controllers.Padding

            return contentView
        }

        let scrollerWidth = scroller.bounds.width
        contentViews.forEach({ scroller.addSubview($0) })

        scroller.contentSize = CGSize(width: xValue, height: frame.size.height)
        scroller.insertSubview(pageControl, aboveSubview: contentViews.last!)

        // 初期位置を設定
        scroller.contentOffset = CGPoint(x: scrollerWidth, y: Controllers.Padding)
        lastScrollerOffset = CGPoint(x: scrollerWidth, y: 0.0)

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

    // called when scroll view grinds to a halt
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newScrollerOffset = scroller.contentOffset
        let width = scrollView.bounds.width
        let direction = Int((newScrollerOffset.x - lastScrollerOffset.x) / width)

        // 右へスクロール
        if direction > 0 {
            print("一番左端のビューを右端へ移動")
            let firstView = contentViews.first!
            contentViews.removeFirst()
            contentViews.insert(firstView, at: contentViews.count)
        }
        else if direction == 0 {
            print("移動なし")
            return;
        }
        // 左へスクロール
        else {
            print("一番右端のビューを左端へ移動")
            let lastView = contentViews.last!
            contentViews.removeLast()
            contentViews.insert(lastView, at: 0)
        }

        var xValue: CGFloat = 0.0

        self.contentViews = contentViews.map {
            (view) -> UIView in

            // 左から順にコンテンツを配置する
            xValue += Controllers.Padding
            view.frame = CGRect(x: xValue,
                                y: Controllers.Padding,
                                width: canvasSize.width,
                                height: canvasSize.height)
            xValue += canvasSize.width + Controllers.Padding

            return view
        }

        scroller.contentOffset = CGPoint(x: width, y: Controllers.Padding)
        lastScrollerOffset = CGPoint(x: width, y: 0.0)

    }

    // MARK: - Private method

    func scrollToDirection(_ step: CGFloat, animated: Bool) {
        let width = UIScreen.main.bounds.width
        let adjustScrollRect = CGRect(x: scroller.contentOffset.x - width * step,
                                      y: scroller.contentOffset.y,
                                      width: scroller.bounds.size.width,
                                      height: scroller.bounds.size.height)
        scroller.scrollRectToVisible(adjustScrollRect, animated: animated)
    }

    private func page(on scrollView: UIScrollView) -> Int {
        let page = (scrollView.contentOffset.x + 1.0) / scrollView.bounds.width
        return Int(page)
    }

}


