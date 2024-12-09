//
//  ImageObject.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import Foundation

/// Represents image information for an aetwork
struct ImageObject: Codable, Equatable, Hashable {
    /// Unique identifier for the image
    let guid: String
    /// URL where the image can be accessed
    let url: URL
    /// Width of the image in pixels
    let width: Int
    /// Height of the image in pixels 
    let height: Int
}
