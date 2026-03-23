# CacheCow

CacheCow is a small Swift package for caching values in memory or on disk.

It includes:

- `Cache`, an in-memory cache backed by `NSCache`
- `CacheArchiver`, a persistence helper for saving and loading `Cache`
- `FileSystemBackedCache`, a cache that stores each value as a separate file
- `Caching`, a shared protocol for basic cache operations

## Requirements

- Swift 6.0+
- iOS 16+
- macOS 13+
- tvOS 14+
- visionOS 1+
- watchOS 9+

## Installation

Add CacheCow to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/CacheCow.git", from: "1.0.0")
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "CacheCow", package: "CacheCow")
    ]
)
```

## Overview

Both cache implementations follow the same core API:

```swift
public protocol Caching {
    associatedtype Key
    associatedtype Value

    var count: Int { get }
    var isEmpty: Bool { get }

    func insert(_ value: Value, for key: Key)
    func value(for key: Key) -> Value?
    func removeValue(for key: Key)
    func clear()

    subscript(key: Key) -> Value? { get set }
}
```

Use `Cache` when you want fast in-memory storage with optional expiration.

Use `FileSystemBackedCache` when values are large, expensive to recreate, or should survive process lifetime by being stored in files.

## Using `Cache`

`Cache` is a generic in-memory cache with Swift-native keys and values.

```swift
import CacheCow

let cache = Cache<String, Data>(
    entryLifetime: 60 * 10,
    countLimit: 100
)

cache.insert(Data(), for: "avatar")

let value = cache.value(for: "avatar")
let sameValue = cache["avatar"]

cache["avatar"] = nil
cache.clear()
```

### Expiration behavior

- `entryLifetime` is measured in seconds.
- If `entryLifetime` is `nil`, cached values do not expire automatically.
- Expired entries are removed when they are accessed.
- `countLimit` is passed through to `NSCache`, which treats it as advisory rather than guaranteed.

## Persisting `Cache` with `CacheArchiver`

`CacheArchiver` lets you save a `Cache` to disk and load it again later.

This requires `Key` and `Value` to conform to `Codable` and `Sendable`.

```swift
import CacheCow

let archiver = CacheArchiver(name: "recent-searches")

let cache: Cache<String, [String]>
do {
    cache = try archiver.load()
} catch {
    cache = Cache()
}

cache.insert(["swift", "caching"], for: "queries")

try await archiver.saveCacheToFile(cache)
```

### When to use `CacheArchiver`

- Use it to restore an in-memory cache between launches.
- Use `name` to choose the cache file name.
- Use `groupID` when the cache should live in an app group container.

`CacheArchiver` is an `actor`, so writes are coordinated safely in concurrent code.

## Using `FileSystemBackedCache`

`FileSystemBackedCache` stores each cached value as raw `Data` in a file chosen by its key.

You provide the encoding and decoding closures, which makes it suitable for images, blobs, or your own serialized types.

Factory methods that create a directory-backed cache take a `URL?`. In normal use, pass a concrete directory URL.

### Create a cache in a known directory

```swift
import CacheCow
import Foundation

let directory = FileManager.default.temporaryDirectory
    .appending(path: "ImageCache", directoryHint: .isDirectory)

let cache = try await FileSystemBackedCache<URL, Data>.urlDirectoryCache(
    at: directory
)

let url = URL(string: "https://example.com/image.png")!
cache.insert(Data(), for: url)

let imageData = cache[url]
```

### Create a cache in the system caches directory for caches that key to URL

```swift
import CacheCow
import Foundation

let directory = try URL.cacheDirectoryURL(named: "RemoteImages")
let cache = try await FileSystemBackedCache<URL, Data>.urlDirectoryCache(at: directory)
```

`cacheDirectoryURL(named:in:)` returns `URL?`. If it returns `nil`, passing that value into `urlDirectoryCache(at:)` causes the cache factory to throw.

Pass `in: "your.app.group"` to `URL.cacheDirectoryURL(named:in:)` when the cache should live in an app group container.

If you already have an optional URL from elsewhere, you can pass it directly:

```swift
let cache = try await FileSystemBackedCache<URL, Data>.urlDirectoryCache(at: directoryURL)
```

That call throws if `directoryURL` is `nil`.

### Using custom value types

For custom types, you can provide callbacks to encode and decode them yourself:

```swift
import CacheCow
import Foundation

struct Profile: Codable, Sendable {
    let name: String
}

let directory = try URL.cacheDirectoryURL(named: "Profiles")
let cache = try await FileSystemBackedCache<URL, Profile>.urlDirectoryCache(
    at: directory,
    encode: { try? JSONEncoder().encode($0) },
    decode: { try? JSONDecoder().decode(Profile.self, from: $0) }
)
```

### Using the JSON convenience factory

When your cached value is `Codable`, you can skip the explicit JSON closures and use `directoryCache(dateProvider:at:)` instead:

```swift
import CacheCow
import Foundation

struct Profile: Codable, Sendable {
    let name: String
}

let directory = URL.cacheDirectoryURL(named: "Profiles")
let cache = try await FileSystemBackedCache<String, Profile>.directoryCache(at: directory)
```

This factory uses `JSONEncoder` and `JSONDecoder` internally. Like the URL-based factories, it throws if the directory URL is `nil`.

### Key behavior

- `URL` already conforms to `CacheKey`.
- `String` already conforms to `CacheKey`.
- You can adopt `CacheKey` on your own types when you need a stable string identifier.

```swift
struct UserID: CacheKey {
    let rawValue: String

    func cacheKey() -> String {
        rawValue
    }
}
```

Choose keys carefully. A stable, unique key is required for correct cache hits.

## Choosing the Right Cache

Use `Cache` when:

- You want fast in-memory lookups
- Automatic eviction through `NSCache` is acceptable
- You want optional expiration support

Use `FileSystemBackedCache` when:

- Values are large
- Values should be stored as files
- Recreating the data is expensive
- You want the cache contents to survive memory pressure

Use `Cache` plus `CacheArchiver` when:

- You want normal in-memory behavior while the app runs
- You also want to save and restore that cache across launches

## Notes

- `FileSystemBackedCache` is available on iOS 16 and macOS 13 or newer.
- Encoding failures in `FileSystemBackedCache` are ignored by design; failed writes simply do not produce a cached value.
- File-backed values are addressed by sanitized string keys derived from `CacheKey`.

## Acknowledgements

The in-memory `Cache` implementation is based on John Sundell's article, ["Caching in Swift"](https://www.swiftbysundell.com/articles/caching-in-swift/), with further modifications for this package.
