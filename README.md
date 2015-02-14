# APMultiMenu

[![Build Status](https://travis-ci.org/Aadeshp/APMultiMenu.svg?branch=master)](https://travis-ci.org/Aadeshp/APMultiMenu)
[![Version](https://img.shields.io/cocoapods/v/APMultiMenu.svg?style=flat)](http://cocoadocs.org/docsets/APMultiMenu)
[![License](https://img.shields.io/cocoapods/l/APMultiMenu.svg?style=flat)](http://cocoadocs.org/docsets/APMultiMenu)
[![Platform](https://img.shields.io/cocoapods/p/APMultiMenu.svg?style=flat)](http://cocoadocs.org/docsets/APMultiMenu)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How To Use

In AppDelegate.m:

```objective-c
UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
UINavigationController *nav = [sb instantiateViewControllerWithIdentifier:@"Nav"];
UIViewController *leftVC = [sb instantiateViewControllerWithIdentifier:@"LeftVC"];
UIViewController *rightVC = [sb instantiateViewControllerWithIdentifier:@"RightVC"];
    
APMultiMenu *apmm = [[APMultiMenu alloc] initWithMainViewController:nav 
                                                           leftMenu:leftVC 
                                                          rightMenu:rightVC];
                                                          
//Add Shadow To Main View
apmm.mainViewShadowEnabled = YES;
apmm.mainViewShadowColor = [UIColor blackColor]; //Default Value
apmm.mainViewShadowRadius = 4.0f; //Default Value
apmm.mainViewShadowOpacity = 0.8f; //Default Value
apmm.mainViewShadowOffset = CGSizeMake(1, 1); //Default Value

//Changing Animation Duration
apmm.animationDuration = 0.4f; //Default Value

self.window.rootViewController = apmm;
[self.window makeKeyAndVisible];
```

To Change Main ViewController From the Slideout Menu:

```objective-c
//Option 1 - Plain ViewController
[self.sideMenuContainerViewController setMainViewController:(UIViewController *)]

//Option 2 - UINavgationController
[self.sideMenuContainerViewController setMainViewController:[[UINavigationController alloc] initWithRootViewController:(UIViewController *)]];
```

Using Delegate Methods

```objective-c
...
    apmm.delegate = self;
...

//Fired BEFORE one of the side menus open up
- (void)sideMenu:(APMultiMenu *)sideMenu willRevealSideMenu:(UIViewController *)sideMenuViewController {
    ...
}

//Fired BEFORE one of the side menus close
- (void)sideMenu:(APMultiMenu *)sideMenu willHideSideMenu:(UIViewController *)sideMenuViewController {
    ...
}
//Fired AFTER one of the side menus open up
- (void)sideMenu:(APMultiMenu *)sideMenu didRevealSideMenu:(UIViewController *)sideMenuViewController {
    ...
}

//Fired AFTER one of the side menus close
- (void)sideMenu:(APMultiMenu *)sideMenu didHideSideMenu:(UIViewController *)sideMenuViewController { 
    ...
}
```

## Installation

APMultiMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "APMultiMenu"
    
---OR---

You can clone the repo:
```
$ git clone https://github.com/Aadeshp/APMultiMenu.git
```
And add the directory ```APMultiMenu/``` to your project

## Author

Aadesh Patel, aadeshp95@gmail.com

## License

APMultiMenu is available under the MIT license. See the LICENSE file for more info.

