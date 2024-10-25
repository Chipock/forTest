//
//  ViewController.swift
//  CombineForTest
//
//  Created by Vadim Volyas on 23.10.2024.
//

import UIKit
import Combine

struct User {
    let name: String
    let age: Int
}

class ViewModel {
    var  user: [User] = [.init(name: "Anton", age: 18),
                         .init(name: "Max", age: 21),
                         .init(name: "Alex", age: 31)]
}

class ViewController: UIViewController {
    
    let viewModel: ViewModel = ViewModel()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21)
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Press", for: .normal)
        
        let action = UIAction { _ in
            self.isTextLabelVisible.toggle()
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        
        return stack
    }()
    
    @Published
    var isTextLabelVisible: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        
        view.addSubview(textLabel)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
        ])
        
        let namePublisher =  NotificationCenter.Publisher(center: .default, name: .userNameChanged)
            .map({ $0.object as? String })
        
        namePublisher
            .assign(to: \.text, on: textLabel)
            .store(in: &cancellables)
        
        $isTextLabelVisible.assign(to: \.isHidden, on: textLabel) // ниже равнозначное значение
//        $isTextLabelVisible.sink  { [weak self] isVisible in
//            self?.textLabel.isHidden = isVisible
//        }
        .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: .userNameChanged, object: "Anton")
    }
}

extension Notification.Name {
    static let userNameChanged = Notification.Name("userNameChanged")
}
