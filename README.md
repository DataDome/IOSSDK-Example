# DataDome

[![Version](https://img.shields.io/cocoapods/v/DataDomeSDK.svg?style=flat)](http://cocoapods.org/pods/DataDomeSDK)
[![License](https://img.shields.io/cocoapods/l/DataDomeSDK.svg?style=flat)](http://cocoapods.org/pods/DataDomeSDK)
[![Platform](https://img.shields.io/cocoapods/p/DataDomeSDK.svg?style=flat)](http://cocoapods.org/pods/DataDomeSDK)

## Installation

DataDomeSDK is available on [CocoaPods](http://cocoapods.org). To get the SDK integrated to your project, simply add the following line to your Podfile:

```ruby
pod "DataDomeSDK"
```

Run `pod install` to download and integrate the framework to your project.

## Getting started

1. Run your application. It is going to crash with the following log
```
Fatal error: [DataDome] Missing DataDomeKey (Your client side key) in your Info.plist
```
2. In your Info.plist, add a new entry with String type, use **DataDomeKey** as key and your actual client side key as value.
3. You can run now the app, it won't crash. You should see a log confirming the SDK is running
```
[DataDome] Version x.y.z
```

Congrats, the DataDome framework is well integrated

## Logging
If you need to see the logs produced by the framework, you can set the log level to control the detail of logs you get

```swift
import DataDomeSDK
DataDomeSDK.setLogLevel(level: .verbose)
```

By default, the framework is completely silent.

The following table contains different logging levels that you may consider using


 Level            			| Description
---------------------------	|----------------------------------------------
__verbose__      			| Everything is logged
__info__      				| Info messages, warnings and errors are shown
__warning__      			| Only warning and errors messages are printed 
__error__      				| Only errors are printed
__none__      				| Silent mode (default)


## Force a captcha display
You can simulate a captcha display using the framework by providing a user agent with the value **BLOCKUA**

To do so:

1. Edit your app scheme
2. Under Run (Debug) > Arguments > Environment Variables, create a new variable
3. Set the name to **DATADOME\_USER\_AGENT** and the value to **BLOCKUA**

The DataDome framework will inject the specified user agent in the requests the app will be sending. Using the **BLOCKUA** user agent value will hint our remote protection module installed on your servers to treat this request as if it is coming from a bot. Which will block it with a captcha response.

Since the DataDome framework retains the cookies after resolving the captcha, this test can be done only the first time you used the BLOCKUA user agent. To reproduce the test case, you can use the following code snippet to manually clear the cookies stored in your app

```swift
for cookie in HTTPCookieStorage.shared.cookies ?? [] {
	HTTPCookieStorage.shared.deleteCookie(cookie)
}
```

## Disable method swizzling
The DataDome Framework is using method swizzling to setup a `proxy` listening to all `URLRequests` performed by the app. The framework will then detect automatically blocked requests, lookup dynamically the top view controller in your app hierarchy and attach a captcha view controller to it. Once resolved, the framework will dismiss the captcha view controller and retry the blocked request with a new generate cookie. All this is done under the hood.

If you want to disable the method swizzling and manually tell the framework which request to monitor instead of monitoring all the traffic or / and you want to manually present and dismiss the captcha controller, please consider the following steps:

1. In your Info.plist, add a new entry with Boolean type, use **DataDomeProxyEnabled** as key and **NO** as value. This will disable method swizzling in the framework.
2. For each request to protect with DataDome, use the following methods to create the data task

```swift
func protectedDataTask(with url: URL,
					 captchaDelegate: CaptchaDelegate?,
					 completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) 
-> URLSessionDataTask
```

```swift
func protectedDataTask(with request: URLSessionRequest,
					 captchaDelegate: CaptchaDelegate?,
					 completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) 
-> URLSessionDataTask
```

Only the `URLSessionDataTasks` created by the above two methods are monitored and protected by DataDome. 

Here a sample code to create and execute a data task

```swift
import DataDomeSDK


guard let url = URL(string: "https://datadome.co") else {
	return
}

let task = URLSession.shared.protectedDataTask(with: url, captchaDelegate: self, completionHandler: { _, _, _ in
	print("Request completed")
})
        
task.resume()
```


To manually manage the presentation of the captcha view controller, implement the `CaptchaDelegate` protocol

```swift
extension MyViewController: CaptchaDelegate {
    func present(captchaController controller: UIViewController) {
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func dismiss(captchaController controller: UIViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
```

Visit the [official documentation](https://docs.datadome.co/docs/sdk-ios) for more details.
