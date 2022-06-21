//
//  ContentView.swift
//  🍣Poses
//
//  Created by Sima Nerush on 6/21/22.
//

import SwiftUI

struct ImagePickerView: View {
    @State private var showImagePicker = false
    @State private var isShowingResultView = false
    
    @State private var image = UIImage()
    
    var body: some View {
        NavigationLink(destination: ResultView(image: $image),
                       isActive: $isShowingResultView) { }
        
        VStack {
            Text("Pick an image with pose")
                .padding()
            Spacer().frame(height: 50)
            Image(uiImage: self.image)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200, alignment: .center)
                .foregroundColor(.white)
                .background(.gray)
                .sheet(isPresented: $showImagePicker,
                        content: {
                     ImagePicker(sourceType: .photoLibrary) { (image, url) in
                        self.image = image
                     }
                 })
            Spacer()
            HStack {
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "doc.badge.plus")
                }.padding()
                Spacer()
                Button {
                    isShowingResultView = true
                } label: {
                    Image(systemName: "checkmark")
                }
                .padding()
            }
        }
        .navigate(to: ResultView(image: $image), when: $isShowingResultView)
    }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView()
    }
}
