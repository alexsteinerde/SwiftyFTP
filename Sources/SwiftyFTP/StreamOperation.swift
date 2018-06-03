import Foundation

/** The base class for stream operations. */
internal class StreamOperation: Operation, StreamDelegate {
    internal let path: String
    internal let queue: DispatchQueue
    private var currentStream: Stream?
    
    init(configuration: SessionConfiguration, queue: DispatchQueue, path: String) {
        self.path = path
        self.queue = queue
        super.init(configuration: configuration)
    }
    
    deinit {
        finishOperation()
    }
    
    fileprivate func configureStream(_ stream: Stream) {
        stream.setProperty(true, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyShouldCloseNativeSocket as String))
        stream.setProperty(true, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPFetchResourceInfo as String))
        stream.setProperty(configuration.passive, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPUsePassiveMode as String))
        stream.setProperty(configuration.username, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPUserName as String))
        stream.setProperty(configuration.password, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPPassword as String))
        stream.delegate = self
    }
    
    var fullUrl: URL {
        return configuration.url.appendingPathComponent(path)
    }
    
    @objc func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if isCancelled {
            streamEventError(aStream)
            error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            finishOperation()
            return
        }
        
        switch eventCode {
        case Stream.Event.openCompleted:
            streamEventOpenComleted(aStream)
        case Stream.Event.hasBytesAvailable:
            streamEventHasBytes(aStream)
        case Stream.Event.hasSpaceAvailable:
            streamEventHasSpace(aStream)
        case Stream.Event.errorOccurred:
            streamEventError(aStream)
            finishOperation()
        case Stream.Event.endEncountered:
            streamEventEnd(aStream)
            finishOperation()
        default:
            print("Unkonwn NSStreamEvent: \(eventCode)")
        }
    }
    
    func startOperationWithStream(_ aStream: Stream) {
        synchronized(self) {
            self.currentStream = aStream
            configureStream(aStream)
            aStream.open()
            state = .executing
        }
    }
    
    func finishOperation() {
        synchronized(self) {
            currentStream?.delegate = nil
            currentStream?.close()
            currentStream = nil
            state = .finished
        }
    }
    
    @discardableResult func streamEventOpenComleted(_ aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    @discardableResult func streamEventEnd(_ aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    @discardableResult func streamEventHasBytes(_ aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    @discardableResult func streamEventHasSpace(_ aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventError(_ aStream: Stream) {
        error = aStream.streamError as NSError?
    }
}
