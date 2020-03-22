import Foundation

extension CSVWriter {
    /// Creates a writer instance that will be used to encode CSV-formatted data.
    /// - parameter configuration: Configuration values specifying how the CSV output should look like.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    public convenience init(configuration: Configuration = .init()) throws {
        let encoding = try CSVWriter.selectEncodingFrom(provided: configuration.encoding, inferred: nil)
        let stream = OutputStream(toMemory: ())
        stream.open()

        let settings = try Settings(configuration: configuration, encoding: encoding)
        let bom = configuration.bomStrategy.bytes(encoding: encoding)
        let encoder = try CSVWriter.makeEncoder(from: stream, encoding: encoding, firstBytes: bom)
        try self.init(configuration: configuration, settings: settings, stream: stream, encoder: encoder)
    }
    
    /// Creates a writer instance that will be used to encode CSV-formatted data into a file pointed by the given URL.
    /// - parameter fileURL: The URL pointing to the targeted file.
    /// - parameter append: In case an existing file is under the given URL, this Boolean indicates that the information will be appended to the file (`true`), or the file will be overwritten (`false`).
    /// - parameter configuration: Configuration values specifying how the CSV output should look like.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    public convenience init(fileURL: URL, append: Bool, configuration: Configuration = .init()) throws {
        #warning("Support file append")
        let encoding = try CSVWriter.selectEncodingFrom(provided: configuration.encoding, inferred: nil)
        guard let stream = OutputStream(url: fileURL, append: append) else { throw Error.invalidFileStream(url: fileURL) }
        stream.open()
        
        let settings = try Settings(configuration: configuration, encoding: encoding)
        let bom = configuration.bomStrategy.bytes(encoding: encoding)
        let encoder = try CSVWriter.makeEncoder(from: stream, encoding: encoding, firstBytes: bom)
        try self.init(configuration: configuration, settings: settings, stream: stream, encoder: encoder)
    }
}

extension CSVWriter {
    /// Creates a writer instance that will be used to encode CSV-formatted data.
    /// - parameter setter: Closure receiving the default configuration values and gives you the possibility to change them.
    /// - parameter configuration: Default configuration values for the `CSVWriter`.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    @inlinable public convenience init(setter: (_ configuration: inout Configuration) -> Void) throws {
        var configuration = Configuration()
        setter(&configuration)
        try self.init(configuration: configuration)
    }
    
    /// Creates a writer instance that will be used to encode CSV-formatted data into a file pointed by the given URL.
    /// - parameter fileURL: The URL pointing to the targeted file.
    /// - parameter append: In case an existing file is under the given URL, this Boolean indicates that the information will be appended to the file (`true`), or the file will be overwritten (`false`).
    /// - parameter setter: Closure receiving the default configuration values and gives you the possibility to change them.
    /// - parameter configuration: Default configuration values for the `CSVWriter`.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    @inlinable public convenience init(fileURL: URL, append: Bool, setter: (_ configuration: inout Configuration) -> Void) throws {
        var configuration = Configuration()
        setter(&configuration)
        try self.init(fileURL: fileURL, append: append, configuration: configuration)
    }
}

// MARK: -

extension CSVWriter {
    /// Returns a `String` with the CSV-encoded representation of the `rows` supplied.
    /// - parameter rows: A sequence of rows whose elements are sequences of `String`-like elements.
    /// - parameter type: The type to encode to.
    /// - parameter configuration: Configuration values specifying how the CSV output should look like.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    /// - returns: Swift `String` containing the formatted CSV data.
    @inlinable public static func serialize<S:Sequence,Sub:Sequence>(rows: S, into type: String.Type, configuration: Configuration = .init()) throws -> String where S.Element==Sub, Sub.Element==String {
        let writer = try CSVWriter(configuration: configuration)
        for row in rows {
            try writer.write(row: row)
        }
        
        try writer.endFile()
        let data = try writer.data()
        return String(data: data, encoding: configuration.encoding ?? .utf8)!
    }
    
    /// Returns a CSV-encoded representation of the `rows` supplied.
    /// - parameter rows: A sequence of rows whose elements are sequences of `String`-like elements.
    /// - parameter type: The type to encode to.
    /// - parameter configuration: Configuration values specifying how the CSV output should look like.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    /// - returns: Data blob in a CSV format.
    @inlinable public static func serialize<S:Sequence,Sub:Sequence>(rows: S, into type: Data.Type, configuration: Configuration = .init()) throws -> Data where S.Element==Sub, Sub.Element==String {
        let writer = try CSVWriter(configuration: configuration)
        for row in rows {
            try writer.write(row: row)
        }
        
        try writer.endFile()
        return try writer.data()
    }
    
    /// Creates a file with the CSV-encoded representation of the `rows` supplied.
    /// - parameter rows: A sequence of rows whose elements are sequences of `String`-like elements.
    /// - parameter fileURL: The URL pointing to the targeted file.
    /// - parameter append: In case an existing file is under the given URL, this Boolean indicates that the information will be appended to the file (`true`), or the file will be overwritten (`false`).
    /// - parameter configuration: Configuration values specifying how the CSV output should look like.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    @inlinable public static func serialize<S:Sequence,Sub:Sequence>(rows: S, into fileURL: URL, append: Bool, configuration: Configuration = .init()) throws where S.Element==Sub, Sub.Element==String {
        let writer = try CSVWriter(fileURL: fileURL, append: append, configuration: configuration)
        for row in rows {
            try writer.write(row: row)
        }
        
        try writer.endFile()
    }
}

extension CSVWriter {
    /// Returns a `String` with the CSV-encoded representation of the `rows` supplied.
    /// - parameter type: The type to encode to.
    /// - parameter rows: A sequence of rows whose elements are sequences of `String`-like elements.
    /// - parameter setter: Closure receiving the default configuration values and gives you the possibility to change them.
    /// - parameter configuration: Default configuration values for the `CSVWriter`.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    /// - returns: Swift `String` containing the formatted CSV data.
    @inlinable public static func serialize<S:Sequence,Sub:Sequence>(rows: S, into type: String.Type, setter: (_ configuration: inout Configuration) -> Void) throws -> String where S.Element==Sub, Sub.Element==String {
        var configuration = Configuration()
        setter(&configuration)
        return try CSVWriter.serialize(rows: rows, into: type, configuration: configuration)
    }
    
    /// Returns a CSV-encoded representation of the `rows` supplied.
    /// - parameter type: The type to encode to.
    /// - parameter rows: A sequence of rows whose elements are sequences of `String`-like elements.
    /// - parameter setter: Closure receiving the default configuration values and gives you the possibility to change them.
    /// - parameter configuration: Default configuration values for the `CSVWriter`.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    /// - returns: Data blob in a CSV format.
    @inlinable public static func serialize<S:Sequence,Sub:Sequence>(rows: S, into type: Data.Type, setter: (_ configuration: inout Configuration) -> Void) throws -> Data where S.Element==Sub, Sub.Element==String {
        var configuration = Configuration()
        setter(&configuration)
        return try CSVWriter.serialize(rows: rows, into: type, configuration: configuration)
    }
    
    /// Creates a file with the CSV-encoded representation of the `rows` supplied.
    /// - parameter fileURL: The URL pointing to the targeted file.
    /// - parameter rows: A sequence of rows whose elements are sequences of `String`-like elements.
    /// - parameter append: In case an existing file is under the given URL, this Boolean indicates that the information will be appended to the file (`true`), or the file will be overwritten (`false`).
    /// - parameter setter: Closure receiving the default configuration values and gives you the possibility to change them.
    /// - parameter configuration: Default configuration values for the `CSVWriter`.
    /// - throws: `CSVError<CSVWriter>` exclusively.
    @inlinable public static func serialize<S:Sequence,Sub:Sequence>(row: S, into fileURL: URL, append: Bool, setter: (_ configuration: inout Configuration) -> Void) throws where S.Element==Sub, Sub.Element==String {
        var configuration = Configuration()
        setter(&configuration)
        try CSVWriter.serialize(rows: row, into: fileURL, append: append, configuration: configuration)
    }
}

// MARK: -

fileprivate extension CSVWriter.Error {
    /// The file with the given URL couldn't be used with an `OutputStream`.
    static func invalidFileStream(url: URL) -> CSVError<CSVWriter> {
        .init(.streamFailure,
              reason: "The output stream couldn't be initialized with the given URL.",
              help: "Make sure you have access to the targeted file.",
              userInfo: ["File URL": url])
    }
    /// The file with the given URL couldn't be used with an `OutputStream`.
    static func stringTranscodingFailed(encoding: String.Encoding) -> CSVError<CSVWriter> {
        .init(.invalidOperation,
              reason: "The output data blob couldn't be transformed into a String.",
              help: "Get in contact with the library maintainer.",
              userInfo: ["Encoding": encoding])
    }
}