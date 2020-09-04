//
//  ContentView.swift
//  OLW - Change Default
//
//  Created by Tiny Apps on 31/8/20.
//

import SwiftUI

class ViewModel:ObservableObject{
    
    init() {
        self.webbrowsers = AppModel.listOfStringCapableAppsIdentifiers("http")
        self.emailreaders = AppModel.listOfStringCapableAppsIdentifiers("mailto")
        self.selectionWebBrowser = AppModel.defaultBrowser() ?? self.webbrowsers.first ?? ""
        self.selectionMailReader = AppModel.defaultMail() ?? self.emailreaders.first ?? ""
    }
    
    @Published var webbrowsers:[String] = []
    @Published var emailreaders:[String] = []
    @Published var selectionWebBrowser:String = ""{
        didSet{
            if AppModel.defaultBrowser() != self.selectionWebBrowser{
                let issuccess = AppModel.setOpenWithAppFor("http", self.selectionWebBrowser)
                print("CHANGE TO \(selectionWebBrowser) is \(issuccess)")
            }
        }
    }
    @Published var selectionMailReader:String = ""{
        didSet{
            if AppModel.defaultMail() != self.selectionMailReader{
                let issuccess =  AppModel.setOpenWithAppFor("mailto", self.selectionMailReader)
                print("CHANGE TO \(selectionMailReader) is \(issuccess)")
            }
        }
    }
    
}


struct ContentView: View {
    @ObservedObject var model:ViewModel = ViewModel()
    
    var body: some View {
        Form{
        Picker(selection: self.$model.selectionWebBrowser, label: Text("Default web browser: ")) {
            ForEach(self.model.webbrowsers, id: \.self) { identifier in
                PreferencesGeneralDefaultPopUpItem(identifier:identifier, isEmailPopUp: false)
            }
        }
        .pickerStyle(PopUpButtonPickerStyle())

        Picker(selection: self.$model.selectionMailReader, label: Text("Default email reader: ")) {
            ForEach(self.model.emailreaders, id: \.self) { identifier in
                PreferencesGeneralDefaultPopUpItem(identifier:identifier, isEmailPopUp: true)
            }
        }
        .pickerStyle(PopUpButtonPickerStyle())
        }
        .padding(.horizontal,50)
        .frame(width:450, height:100)
    }
}


struct PreferencesGeneralDefaultPopUpItem: View {
    let identifier:String
    let isEmailPopUp:Bool
        
    var body: some View {
        HStack{
            Image(nsImage: self.iconImage)
                .resizable()
                .frame(width: 16, height: 16)
            Text(self.appName)
                .frame(maxHeight:20, alignment: .center)
        }
    }
    
    var appName:String{
        return AppModel.appNameFor(self.identifier)
    }
    
    var iconImage:NSImage{
        //need to deliver a sized image already, bug in SWIFTUI 1 cause issue on 10.11
        return AppModel.iconFor(identifier, 16) ?? NSImage()
    }
        
}
