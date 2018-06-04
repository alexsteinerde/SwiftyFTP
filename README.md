# SwiftyFTP
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)

Simple Linux version of "[Rebekka](https://github.com/Constantine-Fry/rebekka) - an FTP/FTPS client in Swift. Utilizes `CFFTPStream` API from `CFNetworking`."

## Implemented FTP commands

+ Directory content listing.
+ Directory creation.
+ File upload/download.

## Installation
Include the following to your `Package.swift` file:
	
	.package(url: "https://github.com/alexsteinerde/SwiftyFTP.git", from: "1.0.0")

## Usage

```swift
var configuration = SessionConfiguration()
configuration.host = "ftp://ftp.mozilla.org:21"
configuration.encoding = NSUTF8StringEncoding
_session = Session(configuration: configuration)
_session.list("/") {
    (resources, error) -> Void in
    println("List directory with result:\n\(resources), error: \(error)\n\n")
}
```

```swift
var configuration = SessionConfiguration()
configuration.host = "127.0.0.1"
_session = Session(configuration: configuration)
_session.download("/Users/foo/testdownload.png") {
   (fileURL, error) -> Void in
   println("Download file with result:\n\(fileURL), error: \(error)\n\n")
}
```

```swift
var configuration = SessionConfiguration()
configuration.host = "localhost:21"
configuration.username = "optimus"
configuration.password = "rollout"
if let URL = NSBundle.mainBundle().URLForResource("testUpload", withExtension: "png") {
   let path = "/Users/foo/bar/testUpload.png"
   _session.upload(URL, path: path) {
       (result, error) -> Void in
       println("Upload file with result:\n\(result), error: \(error)\n\n")
  }
}
```

## Requirements

macOS & Linux: `Swift 4.0.3` or `Swift 4.1`

###License

rebekka is licences under the BSD 2-Clause License ([See License.txt for details.](https://github.com/Constantine-Fry/rebekka/blob/master/License.txt)).

This library is licenced under MIT (see LICENSE file for details).