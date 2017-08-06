public protocol Injectable {
    associatedtype Dependency
}

public protocol ResolverConfiguration {
    associatedtype ProvidableTypes
}
