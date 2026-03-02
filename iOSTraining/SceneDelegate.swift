//
//  SceneDelegate.swift
//  iOSTraining
//
//  Created by FDC.Eyan-NC-SA-IOS on 2/24/26.
//

import UIKit

import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func showLoginScreen(animated: Bool = false) {
        let loginViewController = SigninViewController(
            nibName: String(describing: SigninViewController.self),
            bundle: nil
        )

        setRootViewController(loginViewController, animated: animated)
    }

    func showMainApp(animated: Bool = true) {
        let tabBarController = UITabBarController()

        // Home Tab - Empty placeholder
        let homeVC = UIHostingController(rootView: HomeView())
        homeVC.view.backgroundColor = .systemBackground
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)


        // Shop Tab - Your ProductListViewController
        let shopVC = ProductListViewController()
        let shopNav = UINavigationController(rootViewController: shopVC)
        shopNav.tabBarItem = UITabBarItem(title: "Products", image: UIImage(systemName: "cart"), tag: 1)

        // Cart Tab
        let cartVC = UIHostingController(rootView: Cart())
        cartVC.view.backgroundColor = .systemBackground
        cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 2)

        // wishList Tab
        let wishList = UIViewController()
        wishList.view.backgroundColor = .systemBackground
        wishList.title = "Wishlist"
        let wishlistNav = UINavigationController(rootViewController: wishList)
        wishlistNav.tabBarItem = UITabBarItem(title: "Wishlist", image: UIImage(systemName: "heart"), tag: 3)

        //Settings
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)

        tabBarController.viewControllers = [homeVC, shopNav, cartVC, wishlistNav, settingsVC]
        setRootViewController(tabBarController, animated: animated, useNavigation: false)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                   
        let window = UIWindow(windowScene: windowScene)
        self.window = window
                   
        if isLoggedIn {
            showMainApp(animated: false)
        } else {
            showLoginScreen(animated: true)
        }
        
        
        
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

private extension SceneDelegate {
    func setRootViewController(_ viewController: UIViewController, animated: Bool, useNavigation: Bool = true) {
        guard let window else { return }

        let applyRoot = {
            let wereAnimationsEnabled = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)

            if useNavigation {
                window.rootViewController = UINavigationController(rootViewController: viewController)
            } else {
                window.rootViewController = viewController
            }

            window.makeKeyAndVisible()
            UIView.setAnimationsEnabled(wereAnimationsEnabled)
        }

        guard animated else {
            applyRoot()
            return
        }

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: applyRoot
        )
    }
}
