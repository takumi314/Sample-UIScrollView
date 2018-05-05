//
//  ViewController.swift
//  Sample-UIScrollView
//
//  Created by NishiokaKohei on 2018/04/08.
//  Copyright © 2018年 Kohey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl!

    // ScrollScreenの高さ
    var scrollScreenHeight: CGFloat!
    // ScrollScreenの幅
    var scrollScreenWidth: CGFloat!

    // Images
    let images: [String] = ["DSC07470", "DSC07471", "DSC07472"]


    override func viewDidLoad() {
        super.viewDidLoad()

        let imageSize = UIImage(named: images.first!)!.size

        // ページスクロールとするためにページ幅を合わせる
        scrollScreenWidth = UIScreen.main.bounds.size.width
        scrollScreenHeight = scrollScreenWidth * imageSize.height / imageSize.width

        var valueX: CGFloat = 0.0

        for i in 0 ..< images.count {
            // UIImageViewのインスタンス
            let image = UIImage(named: images[i])!
            let imageView = UIImageView(image: image)

            imageView.frame.origin = CGPoint(x: valueX, y: 100.0)
            imageView.frame.size = CGSize(width: scrollScreenWidth, height: scrollScreenHeight)

            valueX += scrollScreenWidth

            // UIScrollViewのインスタンスに画像を貼付ける
            scrollView.addSubview(imageView)
        }

        // スクロール可能範囲を指定
        let contentSize = CGSize(width: scrollScreenWidth * CGFloat(images.count),
                                 height: scrollView.frame.size.height)
        scrollView.contentSize = contentSize

        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func valueDidChange(_ sender: UIPageControl, forEvent event: UIEvent) {
        var rect = scrollView.frame
        rect.origin.x = rect.size.width * CGFloat(sender.currentPage)
        rect.origin.y = 0.0
        scrollView.scrollRectToVisible(rect, animated: true)
    }

}

extension ViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            let page = (scrollView.contentOffset.x + 1.0) / scrollScreenWidth

            pageControl.currentPage = Int(page)
            pageControl.updateCurrentPageDisplay()
        }
    }

}

