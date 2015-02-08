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
self.window.rootViewController = apmm;
[self.window makeKeyAndVisible];
```

To Change Main ViewController From the Slideout Menu:

```objective-c
//Option 1 - Plain ViewController
[self.menuContainerViewController setMainViewController:(UIViewController *)]

//Option 2 - UINavgationController
[self.menuContainerViewController setMainViewController:[[UINavigationController alloc] initWithRootViewController:(UIViewController *)]];
```

## Requirements

## Installation

APMultiMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "APMultiMenu"

## Author

Aadesh Patel, aadeshp95@gmail.com

## License

APMultiMenu is available under the MIT license. See the LICENSE file for more info.

