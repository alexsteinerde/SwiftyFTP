import Foundation

/** Operation for file uploading. */
internal class FileUploadOperation: WriteStreamOperation {
    fileprivate var fileHandle: FileHandle?
    private let fileUrl: URL
    
    init(configuration: SessionConfiguration, queue: DispatchQueue, path: String, fileUrl: URL) {
        self.fileUrl = fileUrl
        super.init(configuration: configuration, queue: queue, path: path)
    }
    
    override func start() {
        do {
            fileHandle = try FileHandle(forReadingFrom: fileUrl)
            startOperationWithStream(writeStream)
        } catch let error as NSError {
            self.error = error
            fileHandle = nil
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
    }
    
    override func streamEventHasSpace(_ aStream: Stream) -> (Bool, NSError?) {
        guard let fileHandle = fileHandle,
            let writeStream = aStream as? OutputStream else {
                return (true, nil)
        }
        let offsetInFile = fileHandle.offsetInFile
        let data = fileHandle.readData(ofLength: 1024)
        let bytesToWrite = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let writtenBytes = writeStream.write(bytesToWrite, maxLength: data.count)
        if writtenBytes > 0 {
            fileHandle.seek(toFileOffset: offsetInFile + UInt64(writtenBytes))
        } else if writtenBytes == -1 {
            finishOperation()
        }
        return (true, nil)
    }
    
}
