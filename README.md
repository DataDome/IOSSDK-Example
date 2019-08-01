# IOSSDK-Example

[![Badge w/ Version](https://img.shields.io/cocoapods/v/DataDomeSDK)](https://datadome.co/)
![MIT](https://img.shields.io/cocoapods/l/DataDomeSDK)

This sample show you 3 ways to use __DataDomeSDK__:
- URLSession
- Alamofire
- Moya


## Setup
```
pod install
```

**_Note:_** if not working try to :
```
pod deintegrate
pod clean
pod setup
pod install
```

## Usage

It is possible to navigate between the three tabs to test the DataDomeSDK with different integration mode.

##### User Agent
You can change UserAgent between:
- __*ALLOWUA*__ : Request pass Datadome
- __*BLOCKINGUA*__ : Request will be blocked by Datadome and a captcha will be shown.

##### Cache
It is possible to clear cache for triggering captcha again if you want to.

##### Integrations
Each integration is in its own ViewController, so it will be easy to see how implementing DataDomeSDK in your own project.

##### Customization
You can customize endpoint and user agents in `Config.swift` file.

## Documentation

__Documentation__ can be found here:
*https://docs.datadome.co/docs/sdk-ios*

__Changelog__ can be found here:
*https://docs.datadome.co/docs/ios-sdk-changelog*
