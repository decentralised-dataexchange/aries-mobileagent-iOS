///
/// DecodableExtensions.swift
/// CodableExtensions
///
/// Created by David Thorn 26.01.2018
/// Copyright @ 2018 All rights reserved
///
/// Email: david.thorn221278@googlemail.com
///

import Foundation

/// Decodable
///
/// Centralises the user of JSONDecoder and JSONSerialization to a single 
/// extension file so as to avoid repeating the same process for every decodable 
/// object/struct which exists in the project
extension Decodable {

    /// Returns a Decoable object from a Foundation object
    ///
    /// - Parameter:
    ///     - withJsonData: Data a Foundation object
    /// - returns:
    ///     Decodable?
    public static func decode(withJsonData: Data) -> Decodable? {
        do {
            return try JSONDecoder().decode(self, from: withJsonData)
        } catch {
            return nil
        } 
    }

    /// Returns a Decoable object from a NSDictionary
    ///
    /// - Parameter:
    ///     - withDictionary: NSDictionary
    /// - returns:
    ///     Decodable?
    public static func decode(withDictionary: NSDictionary ) -> Decodable? {
        do {
            let data = try JSONSerialization.data(withJSONObject: withDictionary)
            return try JSONDecoder().decode(self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        } 
    }

    /// Returns a Decoable object from a [AnyHashable:Any] Dictionary
    ///
    /// - Parameter:
    ///     - withHashableDictionary: [AnyHashable:Any]
    /// - returns:
    ///     Decodable?
    public static func decode(withHashableDictionary: [AnyHashable:Any] ) -> Decodable? {
        let dictionary = NSDictionary(dictionary: withHashableDictionary)
        return self.decode(withDictionary: dictionary)
    }

     /// Returns a Decoable object from a JSON String
    ///
    /// - Parameter:
    ///     - withJsonString: JSON String
    /// - returns:
    ///     Decodable?
    public static func decode(withJsonString: String ) -> Decodable? {
        guard let data = withJsonString.data(using: .utf8) else { return nil } 
        return self.decode(withJsonData: data)
    }

}
