# DIKit

[![Build Status](https://travis-ci.org/ishkawa/DIKit.svg?branch=master)](https://travis-ci.org/ishkawa/DIKit)

A statically typed dependency injector for Swift.

## Overview

DIKit provides interfaces to express dependency graph. A code generator named `dikitgen` finds implementations of the interfaces, and generate codes which satisfies dependency graph.

The main parts of DIKit are injectable types and provider methods, and both of them are to declare dependencies of types.

Injectable types are types that conform to `Injectable` protocol.

```swift
public protocol Injectable {
    associatedtype Dependency
    init(dependency: Dependency)
}
```

A conformer of `Injectable` protocol must have associated type `Dependency` as a struct. You declare dependencies of the `Injectable` conformer as stored properties of `Dependency` type. For example, suppose we have `ProfileViewController` class, and its dependencies are `User`, `APIClient` and `Database`. Following example code illustrates how to declare dependencies by conforming `Injectable` protocol.

```swift
final class ProfileViewController: Injectable {
    struct Dependency {
        let user: User
        let apiClient: APIClient
        let database: Database
    }

    init(dependency: Dependency) {...}
}
```

Provider methods are methods of inheritor of `Resolver` protocol, which is a marker protocol for code generation.

```swift
public protocol Resolver {}
```

Provider methods declares that which non-injectable types can be instantiated automatically. In the example above, `APIClient` and `Database` are non-injectable type, but they can be provided in the same ways in most cases. In this situation, define provider methods for the types in an inheritor of `Resolver` protocol, so that instances of the types are provided automatically.

```swift
protocol AppResolver: Resolver {
    func provideAPIClient() -> APIClient
    func provideDatabase() -> Database
}
```

In short, we have following situation so far:

- Dependencies of `ProfileViewController` are `User`, `APIClient` and `Database`.
- Instances of `APIClient` and `Database` are provided automatically.
- An instance of `User` must be provided manually to instantiate `ProfileViewController`.

`dikitgen` generates following code for the declarations:

```swift
extension AppResolver {
    func resolveAPIClient() -> APIClient {
        return provideAPIClient()
    }

    func resolveDatabase() -> Database {
        return provideDatabase()
    }

    func resolveViewController(user: User) -> ProfileViewController {
        let apiClient = resolveAPIClient()
        let database = resolveDatabase()
        return ProfileViewController(dependency: .init(user: User, apiClient: apiClient, database: Database))
    }
}
```

To use generated code, you have to implement a concrete type of `AppResolver`.

```swift
final class AppResolverImpl: AppResolver {
    let apiClient: APIClient = ...
    let database: Database = ...

    func provideAPIClient() {
        return apiClient
    }

    func provideDatabase() {
        return database
    }
}
```

Since `AppResolver` is a protocol, all implementations of provider methods are checked at compile time. If you would like to create mock version of `AppResolver` for unit testing, define another concrete type of `AppResolver`. It can be used the same as `AppResolverImpl`.

Now, you can instantiate `ProfileViewController` like below:

```swift
let appResolver = AppResolverImpl()
let user: User = ...
let viewController = appResolver.resolveViewController(user: user)
```

## Requirements

- Code generator: Swift 4.1+ / Xcode 9.4+
- Runtime library: macOS 10.11+ / iOS 9.0+ / watchOS 2.0+ / tvOS 9.0+

## Installation

Install code generator `dikitgen` first.

### [Mint](https://github.com/yonaskolb/mint)

```shell
mint install ishkawa/DIKit dikitgen
```

### From Source

```shell
git clone https://github.com/ishkawa/DIKit.git
cd DIKit
make install
```

Then, integrate DIKit.framework to your project. There are some option to install DIKit.framework.

- **Manual**: Clone this repository and add `DIKit.xcodeproj` to your project.
- **Carthage**: Add a line `github "ishkawa/DIKIt"` to your Cartfile and run `carthage update`.

Optionally, insert shell script running `dikitgen` to early part of build phases.

```shell
if which dikitgen >/dev/null; then
  dikitgen ${SRCROOT}/YOUR_PROJECT > ${SRCROOT}/YOUR_PROJECT/AppResolver.generated.swift
else
  echo "warning: dikitgen not installed, download from https://github.com/ishkawa/DIKit"
fi
```
