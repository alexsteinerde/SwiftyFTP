import Foundation

public typealias ResourceResultCompletionHandler = ([ResourceItem]?, NSError?) -> Void
public typealias FileURLResultCompletionHandler = (URL?, NSError?) -> Void
public typealias BooleanResultCompletionHandler = (Bool, NSError?) -> Void
public typealias DownloadProgressHandler = (Float) -> Void

/** The FTP session. */
open class Session {
    /** The serial private operation queue. */
    fileprivate let operationQueue: OperationQueue
    
    /** The queue for completion handlers. */
    fileprivate let completionHandlerQueue: OperationQueue
    
    /** The serial queue for streams in operations. */
    fileprivate let streamQueue: DispatchQueue
    
    /** The configuration of the session. */
    fileprivate let configuration: SessionConfiguration
    
    public init(configuration: SessionConfiguration,
                completionHandlerQueue: OperationQueue = OperationQueue.main) {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "net.ftp.rebekka.operations.queue"
        streamQueue = DispatchQueue(label: "net.ftp.rebekka.cfstream.queue", attributes: [])
        self.completionHandlerQueue = completionHandlerQueue
        self.configuration = configuration
    }
    
    /** Returns content of directory at path. */
    open func list(_ path: String, completionHandler: @escaping ResourceResultCompletionHandler) {
        let operation = ResourceListOperation(configuration: configuration,
                                              queue: streamQueue,
                                              path: !path.hasSuffix("/") ? path + "/" : path)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperation {
                    completionHandler(strongOperation.resources, strongOperation.error)
                }
            }
        }
        operationQueue.addOperation(operation)
    }
    
    /** Creates new directory at path. */
    open func createDirectory(_ path: String, completionHandler: @escaping BooleanResultCompletionHandler) {
        let operation = DirectoryCreationOperation(configuration: configuration,
                                                   queue: streamQueue,
                                                   path: !path.hasSuffix("/") ? path + "/" : path)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperation {
                    completionHandler(strongOperation.error == nil, strongOperation.error)
                }
            }
        }
        operationQueue.addOperation(operation)
    }
    
    /**
     Downloads file at path from FTP server.
     File is stored in /tmp directory. Caller is responsible for deleting this file. */
    open func download(_ path: String,
                       progressHandler: DownloadProgressHandler? = nil,
                       completionHandler: FileURLResultCompletionHandler? = nil) {
        let operation = FileDownloadOperation(configuration: configuration,
                                              queue: streamQueue,
                                              path: path)
        operation.progressHandler = progressHandler
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperation {
                    completionHandler?(strongOperation.fileURL, strongOperation.error)
                }
            }
        }
        operationQueue.addOperation(operation)
    }
    
    /** Uploads file from fileURL at path. */
    open func upload(_ fileURL: URL, path: String, completionHandler: BooleanResultCompletionHandler? = nil) {
        let operation = FileUploadOperation(configuration: configuration,
                                            queue: streamQueue,
                                            path: path,
                                            fileUrl: fileURL)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperation {
                    completionHandler?(strongOperation.error == nil, strongOperation.error)
                }
            }
        }
        operationQueue.addOperation(operation)
    }
}

public let kFTPAnonymousUser = "anonymous"

/** The session configuration. */
public struct SessionConfiguration {
    /**
     The host of FTP server. Defaults to `localhost`.
     Can be like this:
     ftp://192.168.0.1
     127.0.0.1:21
     localhost
     ftp.mozilla.org
     ftp://ftp.mozilla.org:21
     */
    public var host: String = "localhost"
    
    /* Whether connection should be passive or not. Defaults to `true`. */
    public var passive = true
    
    /** The encoding of resource names. */
    public var encoding = String.Encoding.utf8
    
    /** The username for authorization. Defaults to `anonymous` */
    public var username = kFTPAnonymousUser
    
    /** The password for authorization. Can be empty. */
    public var password = ""
    
    public init() { }
    
    internal var url: URL {
        var components = URLComponents(string: host)
        components?.scheme = "ftp"
        return components?.url ?? URL(fileURLWithPath: "")
    }
}

/** Not secure storage for Servers information. Information is storedin plist file in Cache directory.*/
private class SessionConfigurationStorage {
    
    /** The URL to plist file. */
    fileprivate let storageURL: URL
    
    init?() {
        storageURL = URL(fileURLWithPath: "")
    }
    
    /** Returns an array of all stored servers. */
    fileprivate func allServers() {
        
    }
    
    /** Stores server. */
    fileprivate func storeServer() {
        
    }
    
    /** Deletes server. */
    fileprivate func deleteServer() {
        
    }
    
}

/** Stores credentials in Keychain. */
private class CredentialsStorage {
    
}
