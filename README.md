#  CacheCow

CacheCow is an attempt to write a modern Cache in Swift.

It's based on the article at https://www.swiftbysundell.com/articles/caching-in-swift/

It offers basically two types: 
* `Cache` is a simple key-value cache that stores its data to a single file.
* `FileSystemBackedCache` is a file-system backed cache that stores its data in individual files in a directory, one file for each key/value pair
