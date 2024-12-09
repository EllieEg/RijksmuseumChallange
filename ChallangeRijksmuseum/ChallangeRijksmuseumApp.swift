//
//  ChallangeRijksmuseumApp.swift
//  ChallangeRijksmuseum
//
//  Created by Ellie Egenvall on 2024-12-09.
//

import SwiftUI

@main
struct ChallangeRijksmuseumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(apiKey: Config.apiKey)
        }
    }
}
