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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.layer.cornerRadius = 10
        emailTextfield.layer.borderWidth = 1
        emailTextfield.layer.borderColor = UIColor.blue.cgColor
        emailTextfield.layer.masksToBounds = true
        
        let emailPaddingView = UIView()
        emailPaddingView.frame.size = CGSize(
            width: 10,
            height: emailTextfield.frame.height
        )
        emailTextfield.leftView = emailPaddingView
        emailTextfield.leftViewMode = .always
        
        passwordTextfield.layer.cornerRadius = 10
        passwordTextfield.layer.borderWidth = 1
        passwordTextfield.layer.borderColor = UIColor.blue.cgColor
        passwordTextfield.layer.masksToBounds = true
        
        let passwordPaddingView = UIView()
        passwordPaddingView.frame.size = CGSize(
            width: 10,
            height: emailTextfield.frame.height
        )
        passwordTextfield.leftView = passwordPaddingView
        passwordTextfield.leftViewMode = .always
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        let email = emailTextfield.text ?? ""
        let pass = passwordTextfield.text ?? ""

        
//        guard !email.isEmpty, !pass.isEmpty else {
//           return
//        }


        

        let productListVC = ProductListViewController()
        self.navigationController?.pushViewController(productListVC, animated: true)
        
        
        
        
        
        
        
//        let vc = TestViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        
        //productListVC.modalTransitionStyle = .fullscreen

        
        
        // push - pop
        // present - dismiss
  //      let productListVC = ProductListViewController()
        //productListVC.modalTransitionStyle = .fullscreen
        //self.present(productListVC, animated: true)
 //               self.navigationController?.pushViewController(
  //                  productListVC, animated: true)
        
        
        
        
        
        
        
        
        
        
        
        
        
        // modal
        //self.present(UIViewController, animated: true)
    
        
        // push
//        self.navigationController?.pushViewController(
//            productListVC, animated: true)
            

        
        
//        let navivationController = UINavigationController(
//            rootViewController: productListVC
//        )
//
        
        
        
    }
}

