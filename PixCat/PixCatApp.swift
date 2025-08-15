//
//  PixCatApp.swift
//  PixCat
//
//  Created by Felipe Hernández on 15/08/25.
//

import SwiftUI

@main
struct PixCatApp: App {
    @NSApplicationDelegateAdaptor(PixCatDelegate.self) var pixCatDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
