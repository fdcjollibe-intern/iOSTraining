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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Email field
        styleContainer(emailContainerView)
        styleTextField(emailTextfield, placeholder: "Enter your email", icon: "envelope")

        // Password field
        styleContainer(passwordContainerView)
        styleTextField(passwordTextfield, placeholder: "Enter your password", icon: "lock")
        passwordTextfield.isSecureTextEntry = true

        // Login button
        loginButton.layer.cornerRadius = 14
        loginButton.clipsToBounds = true
        loginButton.backgroundColor = UIColor(red: 0x21/255.0, green: 0xB4/255.0, blue: 0x85/255.0, alpha: 1.0)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }

    private func styleContainer(_ view: UIView) {
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.88, alpha: 1.0).cgColor
        view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        view.clipsToBounds = true
    }

    private func styleTextField(_ textField: UITextField, placeholder: String, icon: String) {
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = .label
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        // Left icon
        let iconView = UIImageView(frame: CGRect(x: 14, y: 0, width: 18, height: 18))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor(white: 0.6, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 50))
        containerView.addSubview(iconView)
        iconView.center = CGPoint(x: containerView.frame.width / 2, y: containerView.frame.height / 2)

        textField.leftView = containerView
        textField.leftViewMode = .always

        // Placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.65, alpha: 1.0),
                         .font: UIFont.systemFont(ofSize: 15)]
        )
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        let email = emailTextfield.text ?? ""
        let pass = passwordTextfield.text ?? ""

        guard !email.isEmpty, !pass.isEmpty else {
            shakeFields()
            return
        }

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
