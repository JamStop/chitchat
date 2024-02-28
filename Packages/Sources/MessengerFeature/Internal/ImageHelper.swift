// Created by Jimmy Yue in 2024

import Foundation
import SwiftUI

// Required as a result of an issue packages image resources into
// the module's asset catalogue.
// SwiftUI expects the asset to come from a traditional asset catalogue,
// despite the Image(name:bundle:) declaration promising otherwise.
// Extension pulled from:
// https://www.enekoalonso.com/articles/displaying-images-in-swiftui-views-from-swift-package-resources
extension Image {
    init(packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path)
        else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path)
        else {
            self.init(name)
            return
        }
        self.init(nsImage: image)
        #else
        self.init(name)
        #endif
    }
}
