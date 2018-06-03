import Foundation

/** The base class for read stream operations. */
internal class ReadStreamOperation: StreamOperation {
    
    internal lazy var temporaryBuffer: UnsafeMutablePointer<UInt8> = {
        return UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
    }()
    
    lazy var readStream: InputStream = {
        let cfStream = CFReadStreamCreateWithFTPURL(nil, fullUrl as CFURL)
        CFReadStreamSetDispatchQueue(cfStream.takeUnretainedValue(), queue)
        return cfStream.takeRetainedValue()
    }()
    
    override func start() {
        startOperationWithStream(readStream)
    }
}
