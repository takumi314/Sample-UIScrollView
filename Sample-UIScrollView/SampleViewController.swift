//
//  SampleViewController.swift
//  Sample-UIScrollView
//
//  Created by NishiokaKohei on 2018/04/14.
//  Copyright © 2018年 Kohey. All rights reserved.
//

import UIKit

typealias ImageName = String

class SampleViewController: UIViewController {

    @IBOutlet weak var canvasView: UIView!

    private var scrollerView: HorizontalScrollerView!

    // Images
    let images: [ImageName] = ["DSC07470", "DSC07471", "DSC07472"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollerView = HorizontalScrollerView(frame: canvasView.bounds)
        canvasView.addSubview(scrollerView)
        scrollerView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SampleViewController: HorizontalScrollerViewDataSource {
    func numberOfViewa(in horizontalScrollerView: HorizontalScrollerView) -> Int {
        return images.count
    }

    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView {
        let image = UIImage(named: images[index])!
        return UIImageView(image: image)
    }
}
