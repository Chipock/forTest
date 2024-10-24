//
//  ViewController.swift
//  CombineForTest
//
//  Created by Vadim Volyas on 23.10.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        
        // Publisher
        
        let publisher = Just("Hello world!")
        
        let arryaPublisher = ["1", "2", "3"].publisher
        
        // Subscribe
        
        publisher.sink { _ in
            print("Value recieved")
            // срабатывает после того как вы получили новое значение
        } receiveValue: { value in
            print("This value: \(value)")
        }
        
        arryaPublisher.sink { value in
            print("Array value: \(value)")
        }
    }
    

}

