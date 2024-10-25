//
//  ViewController.swift
//  CombineForTest
//
//  Created by Vadim Volyas on 23.10.2024.
//

import UIKit
import Combine

struct User: Codable {
    let name: String
    let age: Int
}

class ViewModel {
    
    private var cancellables: Set<AnyCancellable> = []
    @Published var users: [User] = [.init(name: "Anton", age: 18),
                         .init(name: "Max", age: 21),
                         .init(name: "Alex", age: 31)]
    
    var bithDayDateSubject: PassthroughSubject<Date, Never> = .init()
    let userServise = UserService()
    
    func obtainUsers() {
        userServise.obtainUsers()
            .subscribe(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error)")
                default: break
                }
            } receiveValue: { [weak self] users in
                self?.users = users
            }.store(in: &cancellables)

    }
    
    func obtainUsrtBirhDayDate() {
        let date = Date()
        bithDayDateSubject.send(date)
    }
    
    func addRandomUser() {
        users.append(.init(name: "New User \(Int.random(in: 0 ..< 10))", age: 32))
    }
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
            self.viewModel.addRandomUser()
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
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.borderStyle = .line
        field.placeholder = "Password"
        return field
    }()
    
    @Published
    var isTextLabelVisible: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{6,}$")
        
        textField.textPublisher
            .debounce(for: 0.5 , scheduler: DispatchQueue.main) // здаержка между тем что ввели и отработали в поиске удобно
//            .removeDuplicates() // удаление одного и того же символа
            .map({ passwordPredicate.evaluate(with: $0) })
            .sink { value in
                print("Text field is valid: \(value)")
            }
            .store(in: &cancellables)
        
        configureBindings()
    }
    
    func configureBindings() {
        let namePublisher =  NotificationCenter.Publisher(center: .default, name: .userNameChanged)
            .map({ $0.object as? String })
        
        namePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: textLabel)
            .store(in: &cancellables)
        
        $isTextLabelVisible.assign(to: \.isHidden, on: textLabel) // ниже равнозначное значение
            .store(in: &cancellables)
        
        viewModel.bithDayDateSubject // новые подписчики не будут получать старых изменений
            .sink { userDate in
                print("User date: \(userDate)")
            }
            .store(in: &cancellables)
        
        viewModel.$users
        //            .dropFirst() // дропает первый вызов
            .sink { [weak self] users in
                for user in users {
                    self?.addUserLabel(by: user)
                }
            }
            .store(in: &cancellables)
    }
    
    func addUserLabel(by user: User) {
        
        guard stackView.subviews
            .map({ $0 as? UILabel })
            .filter({ $0?.text == user.name })
            .isEmpty else { return }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21)
        label.text = user.name
        
        stackView.addArrangedSubview(label)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: .userNameChanged, object: "Anton")
        }
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)
            .compactMap({ $0.object as? UITextField })
            .map({ $0.text ?? "" })
            .eraseToAnyPublisher()
    }
}

extension Notification.Name {
    static let userNameChanged = Notification.Name("userNameChanged")
}
