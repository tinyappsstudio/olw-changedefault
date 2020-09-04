//
//  Model.swift
//  OLW - Change Default
//
//  Created by Tiny Apps on 31/8/20.
//

import Cocoa
import CoreServices

class AppModel{

    //Retreive the default apps
    static func defaultBrowser() -> String?{
        return self.defaultAppFor("http:")
    }
    
    static func defaultMail() -> String?{
        return self.defaultAppFor("mailto:")
    }
    
    static func defaultAppFor(_ type:String) -> String?{
        let url:URL? = URL(string: type)
        if (url == nil) {return nil}
        let res =  (LSCopyDefaultApplicationURLForURL(url! as CFURL, .all, nil)?.takeRetainedValue() as URL?)
        let bunid:String? = Bundle(url: res!)?.infoDictionary?["CFBundleIdentifier"] as? String
        return bunid
    }
    
    //Retreive the all the app capable to open a type of url
    static func listOfStringCapableAppsIdentifiers(_ type:String) -> [String] {
        return self.newListOfStringCapableAppsIdentifiers(type)
    }
    
    static func newListOfStringCapableAppsIdentifiers(_ type:String) -> [String] {
        //The new way to get the list of app. Nice but less result than the deprecated way
        let apps:[URL]? = (LSCopyApplicationURLsForURL(URL(string: type + ":")! as CFURL, .all)?.takeRetainedValue() as? [URL])
        let res:[String] = apps?.compactMap{Bundle(url: $0)?.infoDictionary?["CFBundleIdentifier"] as? String} ?? []
        return res.unique(for: \.self)
    }
    
    //set the default app for the type of url
    static func setOpenWithAppFor(_ type:String, _ bundleIdentifier:String) -> Bool{
        let status = LSSetDefaultHandlerForURLScheme(type as CFString, bundleIdentifier as CFString)
        return (status == 0)
    }
    
    
    //Some convenient methods for the UI
    static func iconFor(_ bundleIdentifier:String, _ size:CGFloat = 128) -> NSImage?{
        let path:String? = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleIdentifier)
        if (path == nil) {return nil}
        let rep = NSWorkspace.shared.icon(forFile: path!).bestRepresentation(for: NSRect(x: 0, y: 0, width: size, height: size), context: nil, hints: nil)
        if (rep == nil) {return nil}
        let image = NSImage.init(size: CGSize(width: size, height: size))
        image.addRepresentation(rep!)
        return image
    }
    
    static func appNameFor(_ bundleIdentifier:String?) -> String{
        let defaultName = "Unknown"
        if bundleIdentifier == nil {return defaultName}
        let path:String? = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleIdentifier!)
        if (path == nil) {return defaultName}
        let url:URL? = URL(fileURLWithPath: path!)
        if (url == nil) {return defaultName}
        
        if (Bundle(url: url!) != nil){
            let appname:String = Bundle(url: url!)?.infoDictionary?["CFBundleName"] as? String ?? defaultName
            return appname
        }else{
            let suggestedAppName:String = url?.deletingPathExtension().lastPathComponent ?? defaultName
            return suggestedAppName
        }
    }
    

}

extension Sequence {
    /// Returns an array containing, in order, the first instances of
    /// elements of the sequence that compare equally for the keyPath.
    func unique<T: Hashable>(for keyPath: KeyPath<Element, T>) -> [Element] {
        var unique = Set<T>()
        return filter { unique.insert($0[keyPath: keyPath]).inserted }
    }
}
