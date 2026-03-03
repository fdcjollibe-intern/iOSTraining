//
//  ViewController.swift
//  iOSTraining
//
//  Created by FDC.Eyan-NC-SA-IOS on 2/24/26.
//

import UIKit

class SigninViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    private var gradientLayer: CAGradientLayer?
    private var loginButtonGradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        
        // Update button gradient frame
        if let buttonGradient = loginButtonGradient {
            buttonGradient.frame = loginButton.bounds
        }
    }

    private func setupUI() {
        // Add gradient background
        addGradientBackground()
        
        // Email field
        styleContainer(emailContainerView)
        styleTextField(emailTextfield, placeholder: "Enter your email", icon: nil)

        // Password field
        styleContainer(passwordContainerView)
        styleTextField(passwordTextfield, placeholder: "Enter your password", icon: nil)
        passwordTextfield.isSecureTextEntry = true
        
        // Add eye icon for password toggle
        addPasswordToggle()

        // Login button with gradient
        styleLoginButton()
    }
    
    private func addGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        // Green gradient
        gradient.colors = [
            UIColor(red: 87/255.0, green: 175/255.0, blue: 135/255.0, alpha: 1.0).cgColor,
            UIColor(red: 60/255.0, green: 140/255.0, blue: 110/255.0, alpha: 1.0).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    private func styleContainer(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        view.backgroundColor = .white
        view.clipsToBounds = true
    }

    private func styleTextField(_ textField: UITextField, placeholder: String, icon: String?) {
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = .label
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        // Placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.65, alpha: 1.0),
                         .font: UIFont.systemFont(ofSize: 15)]
        )
    }
    
    private func addPasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        containerView.addSubview(button)
        button.center = containerView.center
        
        passwordTextfield.rightView = containerView
        passwordTextfield.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTextfield.isSecureTextEntry = !sender.isSelected
    }
    
    private func styleLoginButton() {
        loginButton.layer.cornerRadius = 14
        loginButton.clipsToBounds = true
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        // Add green gradient
        let gradient = CAGradientLayer()
        gradient.frame = loginButton.bounds
        gradient.colors = [
            UIColor(red: 87/255.0, green: 175/255.0, blue: 135/255.0, alpha: 1.0).cgColor,
            UIColor(red: 60/255.0, green: 140/255.0, blue: 110/255.0, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.cornerRadius = 14
        
        loginButton.layer.insertSublayer(gradient, at: 0)
        loginButtonGradient = gradient
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        let email = emailTextfield.text ?? ""
        let pass = passwordTextfield.text ?? ""

        guard !email.isEmpty, !pass.isEmpty else {
            shakeFields()
            return
        }

        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(email, forKey: "userName")
        UserDefaults.standard.synchronize()
        
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.showMainApp()
        }
    }

    private func shakeFields() {
        let fields = [emailContainerView, passwordContainerView]
        fields.forEach { field in
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.4
            animation.values = [-8, 8, -6, 6, -4, 4, 0]
            field?.layer.add(animation, forKey: "shake")
        }
    }
}
