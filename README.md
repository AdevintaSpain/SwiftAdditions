# Additions

[![Build status](https://badger.engprod-pro.mpi-internal.com/badge/travis/scmspain/ios-common--lib-additions)](https://badger.engprod-pro.mpi-internal.com/redirect/travis/scmspain/ios-common--lib-additions)
[![Version](https://img.shields.io/cocoapods/v/Additions.svg?style=flat)](https://cocoapods.org/pods/Additions)
[![License](https://img.shields.io/cocoapods/l/Additions.svg?style=flat)](https://cocoapods.org/pods/Additions)
[![Platform](https://img.shields.io/cocoapods/p/Additions.svg?style=flat)](https://cocoapods.org/pods/Additions)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

There's multiple niceties in this repo anyone in Adevinta might be able to use

### Additions
- `CoreServiceLocator` simplification using `@Inject` 
- `Dispatching` for easy handling of `DispatchQueue` and `GCD`
- `AsyncOperation` simple wrapper over `NSOperation`
- [AppTasks](Documentation/AppTasks.md) in conjuction with `AppTask: AsyncOperation` and `ServiceProvider` will provide a coordinated way to start any application.

### Extensions and Syntax Sugar:
- Array
- Binding
- ProcessInfo
- SafeInitialisers for Foundation stuff
- String
- URL
- ProcessInfo
- Dictionary


## Requirements

- iOS > 13

## Installation

Additions is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Additions'
```

## Author

Marton Kerekes, marton.kerekes@adevinta.com

## License

Additions is available under the MIT license. See the LICENSE file for more info.