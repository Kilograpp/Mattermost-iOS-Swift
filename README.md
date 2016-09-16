![alt text](https://pp.vk.me/c604823/v604823883/7413/otnLESgiLSk.jpg "Logo Title Text 1")



[![Build Status](https://travis-ci.org/Kilograpp/Mattermost-iOS-Swift.svg?branch=master)](https://travis-ci.org/Kilograpp/Mattermost-iOS-Swift)  [![codebeat badge](https://codebeat.co/badges/a4d115a0-c907-41fc-a31d-4f614c9bc5cf)](https://codebeat.co/projects/github-com-kilograpp-mattermost-ios-swift)

# Mattermost iOS Native Application 

This is fully native Mattermost iOS application written in pure Swift. 


**Note** The iOS app is **not** an [official](https://github.com/mattermost/ios) and made by enthusiasts. So any backend changes might take some time to be implemented in the app.
But no worries. We use the app for own needs so an update will be not long in coming. 

iOS application for use with Mattermost server 3.0 and higher (http://www.mattermost.org/download/) 

#### Supported Platforms 

- iOS **8.1+** iPhone and iPod Touch devices _(iPad is coming soon)_

#### Requirements for Deployment 

1. Understanding of [Mattermost push notifications](http://docs.mattermost.com/administration/config-settings.html#push-notification-settings). 
2. Experience compiling and deploying iOS applications either to iTunes or an Enterprise App Store 
3. An Apple Developer account and appropriate Apple devices to compiled, test and deploy the application
4. Cocoapods & Carthage installed

***

#### Installation 

1. Install [Mattermost 3.0 or higher](http://www.mattermost.org/download/).
2. Change the app bundle id to your own.
3. Run `pod install` in the project's root directory. This will fetch Cocoapods dependencies.
If CocoaPods is not already available it could be installed by:
 
 ``` 
$ [sudo] gem install cocoapods
 ``` 

4. Run `carthage update --platform iOS`. This will fetch Carthage dependencies. 
If Carthage is not already available it could be installed using this [tutorial](https://github.com/Carthage/Carthage#installing-carthage) 
5. Compile and deploy this iOS application to your Enterprise AppStore or publicly.
6. Install [the latest stable release of the Mattermost Push Notifications Server](https://github.com/mattermost/push-proxy) using the private and public keys generated for your iOS application from step 2. 
7. In the Mattermost Platform Server go to **System Console** > **Email Settings** > **Push Notifications Server** and add the web address of the Mattermost Push Notifications Server. Set **System Console** > **Send Push Notifications** to `true`.
8. On your iOS device, download and install your app and enter the **Team URL** and credentials based on a team set up on your Mattermost Platform Server 
