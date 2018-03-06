//
//  DetailViewController.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/02.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var repository: Repository? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        LogUtil.traceFunc()
        
        // Update the user interface for the detail item.
        if let repository = repository {
            if let label = detailDescriptionLabel {
                label.text = repository.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LogUtil.traceFunc()
        
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        LogUtil.traceFunc()
        // Dispose of any resources that can be recreated.
    }

}

