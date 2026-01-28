//
//  ViewController.swift
//  compresser
//
//  Created by Misha Causur on 26.01.2026.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let helper = ZlibHelper()

        let original = Data("hello hello hello hello hello".utf8)
        let compressed = try! helper.compress(original)

        print("original:", original.count) // 29
        print("compressed:", compressed.count) // 17
        
        let restored = try! helper.decompress(compressed)
        print("restored:", restored.count) // 29
        print("restored == original:", restored == original)
        print(String(data: restored, encoding: .utf8)!)
    }


}

