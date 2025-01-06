#  CacheCow

CacheCow is a simple modern Cache in Swift.

It offers basically two types, both of which follow the `Caching` protocol: 

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

## `Cache` is a simple, in-memory, key-value cache. 
It's a wrapper for NSCache, but with Swift semantics. It's able to cache pretty much any swift type, not just NSObject.

It's based on the article at https://www.swiftbysundell.com/articles/caching-in-swift/
by John Sundell, and follows his example very closely. 

It offers the ability to be saved to disk 

## `FileSystemBackedCache` is a file-system backed cache 
It stores its data in individual files in a directory, one file for each key/value pair. It's useful for caching large blobs of data like images retrieved from the network.
 
