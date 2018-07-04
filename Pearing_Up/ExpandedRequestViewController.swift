//
//  ExpandedRequestViewController.swift
//  Pearing_Up
//
//  Created by Ali Arshad on 2018-07-04.
//  Copyright © 2018 Manan Maniyar. All rights reserved.
//

import UIKit

class ExpandedRequestViewController: UIViewController {

    @IBOutlet weak var descriptionUI: UILabel!
    @IBOutlet weak var nameUI: UILabel!
    var requestDespcription : String?
    var requestName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionUI.text = requestDespcription
        self.nameUI.text = requestName
        print(requestName)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        descriptionUI.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
