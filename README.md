# DIKit

[![Build Status](https://travis-ci.org/ishkawa/DIKit.svg?branch=master)](https://travis-ci.org/ishkawa/DIKit)

An experimental project that provides static dependency injection by code generation.

## Overview

DIKit generates code that resolves dependency graph.

First, Declare dependency in the stored property of `Dependency`.

```swift
final class ViewController: Injectable {
    struct Dependency {
        let apiClient: APIClient
    }

    init(dependency: Dependency) {}
}

final class APIClient {}

protocol AppResolver: Resolver {
    func provideAPIClient() -> APIClient
}
```

In this case, `ViewController` depends on `APIClient`, and `APIClient` is provided in `provideAPIClient()` method in `AppResolver`.

Next, you can generate code in protocol extension by `dikitgen <source_directory>` that resolves dependency graph.

```swift
extension AppResolver {
    func resolveAPIClient() -> APIClient {
        return provideAPIClient()
    }

    func resolveViewController() -> ViewController {
        let apiClient = resolveAPIClient()
        return ViewController(dependency: .init(apiClient: apiClient))
    }
}
```

This generated code resolves dependency graph that `ViewController` depends on `APIClient`.

## Installation

Install code generator `dikitgen` first.

```
git clone https://github.com/ishkawa/DIKit.git
cd DIKit
make install
```

Then, integrate DIKit.framework to your project. There are some option to install DIKit.framework.

### Manual

Clone this repository and add `DIKit.xcodeproj` to your project.

### Carthage

Add following line into your Cartfile and run `carthage update`.

```
github "ishkawa/DIKit"
```
