import Foundation

/** The base class for write stream operatons. */
internal class WriteStreamOperation: StreamOperation {
    
    lazy var writeStream: OutputStream = {
        let cfStream = CFWriteStreamCreateWithFTPURL(nil, fullUrl as CFURL)
        CFWriteStreamSetDispatchQueue(cfStream.takeUnretainedValue(), queue)
        return cfStream.takeRetainedValue()
    }()
    
    internal override func start() {
        startOperationWithStream(writeStream)
    }
}
