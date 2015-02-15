//
// APMultiMenuConstants.h
// APMultiMenu
//
// Copyright (c) 2015 Aadesh Patel <aadeshp95@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#ifndef APMultiMenu_APMultiMenuConstants_h
#define APMultiMenu_APMultiMenuConstants_h

static CGFloat const kMENU_WIDTH = 260.0f;
static CGFloat const kMENU_INDENT_DIV = 5.0f;
static CGFloat const kMENU_INDENT = kMENU_WIDTH / kMENU_INDENT_DIV;

typedef NS_ENUM (NSInteger, APMultiMenuType) {
    APMultiMenuTypeLeftMenu,
    APMultiMenuTypeRightMenu
};

typedef NS_ENUM (NSInteger, APMultiMenuTransition) {
    APMultiMenuTransitionNone,
    APMultiMenuTransitionToLeft,
    APMultiMenuTransitionResetFromLeft,
    APMultiMenuTransitionToRight,
    APMultiMenuTransitionResetFromRight
};

typedef NS_ENUM (NSInteger, APMultiMenuViewController) {
    APMultiMenuViewControllerMain,
    APMultiMenuViewControllerLeft,
    APMultiMenuViewControllerRight
};

typedef NS_ENUM (NSInteger, APMultiMenuMainViewPosition) {
    APMultiMenuMainViewPositionDefault,
    APMultiMenuMainViewPositionLeft,
    APMultiMenuMainViewPositionRight
};

typedef NS_ENUM (NSInteger, APMultiMenuStatus) {
    APMultiMenuStatusOpen,
    APMultiMenuStatusClose
};

#endif
