import Foundation

/** Operation for downloading a file from FTP server. */
internal class FileDownloadOperation: ReadStreamOperation {
    
    private var fileHandle: FileHandle?
    var fileURL: URL?
    var progressHandler: DownloadProgressHandler?
    
    override func start() {
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(path )
        let fileURL = URL(fileURLWithPath: filePath)
        self.fileURL = fileURL
        do {
            try Data().write(to: fileURL, options: NSData.WritingOptions.atomic)
            fileHandle = try FileHandle(forWritingTo: fileURL)
            startOperationWithStream(readStream)
        } catch let error as NSError {
            self.error = error
            finishOperation()
        }
    }
    
    override func streamEventEnd(_ aStream: Stream) -> (Bool, NSError?) {
        fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(_ aStream: Stream) {
        super.streamEventError(aStream)
        fileHandle?.closeFile()
        if let fileURL = self.fileURL {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch _ {
            }
        }
        fileURL = nil
    } 
    
    override func streamEventHasBytes(_ aStream: Stream) -> (Bool, NSError?) {
        guard let totalBytesSize = aStream.property(forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPResourceSize as String)) as? Int,
            let inputStream = aStream as? InputStream,
            let fileHandle = self.fileHandle else {
                return (true, nil)
        }
        
        var downloadedBytes: Int = 0
        var parsedBytes: Int = 0
        repeat {
            parsedBytes = inputStream.read(temporaryBuffer, maxLength: 65536)
            downloadedBytes += parsedBytes
            progressHandler?(Float(downloadedBytes) / Float(totalBytesSize))
            if parsedBytes > 0 {
                autoreleasepool {
                    let data = Data(bytes: UnsafePointer<UInt8>(temporaryBuffer), count: parsedBytes)
                    fileHandle.write(data)
                }
            }
        } while (parsedBytes > 0)
        return (true, nil)
    }
}
