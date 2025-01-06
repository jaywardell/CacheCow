#  CacheCow

CacheCow is an attempt to write a modern Cache in Swift.

It offers basically two types: 
## `Cache` is a simple key-value cache. 
It's a wrapper for NSCache, but with Swift semantics and able to cache pretty much any swift type, not just NSObject.

It's based on the article at https://www.swiftbysundell.com/articles/caching-in-swift/
by by John Sundell, and follows his example very closely. 

## `FileSystemBackedCache` is a file-system backed cache 
It stores its data in individual files in a directory, one file for each key/value pair. Useful for caching large blobs of data like images retrieved from the network.
