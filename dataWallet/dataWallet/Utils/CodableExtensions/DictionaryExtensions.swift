import Foundation

extension NSDictionary {

    /// Converts a NSDictionary to a Dedocable Optional
    ///
    /// - Parameters:
    ///     - docodable: Decodable.Type The type which this NSDictionaty should be decoded into
    /// - returns: Decodable?
    public func to(_ decodable: Decodable.Type ) -> Decodable? {
        return decodable.decode(withDictionary: self)
    }

}

extension Dictionary where Key == String , Value == Any {

    /// Converts a Dictionary<String,Any> to a Decodable Optional
    ///
    /// - Parameters:
    ///     - docodable: Decodable.Type The type which this NSDictionaty should be decoded into
    /// - returns: Decodable?
    public func to(_ decodable: Decodable.Type ) -> Decodable? {
        return decodable.decode(withHashableDictionary: self)
    }

}

extension Dictionary where Key == AnyHashable , Value == Any {

    /// Converts a Dictionary<AnyHashable,Any> to a Decodable Optional
    ///
    /// - Parameters:
    ///     - docodable: Decodable.Type The type which this NSDictionaty should be decoded into
    /// - returns: Decodable?
    public func fromAnyHashableTo(_ decodable: Decodable.Type ) -> Decodable? {
        return decodable.decode(withHashableDictionary: self)
    }

}