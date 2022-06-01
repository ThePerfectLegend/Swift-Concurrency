//
//  DoCatchTryThrows.swift
//  Swift Concurrency
//
//  Created by Nizami Tagiyev on 01.06.2022.
//

import SwiftUI

// do - catch
// try
// throws

class KeyWordsDataManager {
    
    let isActive = false
    
    // MARK: Default behaviour without key words
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("New Text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    
    // MARK: Result behaviour with tuple
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text")
        } else {
            return .failure(URLError(.badURL))
        }
    }
     
    // MARK: Throws behaviour

    func getTitle3() throws -> String {
        if isActive {
            return ("New Text")
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
}

class KeyWordsViewModel: ObservableObject {
    
    @Published var text: String = "String text"
    let manager = KeyWordsDataManager()
    
    
    
    func fetchTitle() {
     // MARK: Default behaviour without key words
        /*
        let returnedValue = manager.getTitle()
         
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        
    // MARK: Result behaviour with tuple
        /*
        let result = manager.getTitle2()
        
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
         */
        
    // MARK: Optional try?
        // Use instead of to-catch if error is no matter
        
        let newTitle = try? manager.getTitle4()
        if let newTitle = newTitle {
            self.text = newTitle
        }
        
    // MARK: Throws behaviour
        do {
            let newTitle = try manager.getTitle3()
            self.text = newTitle
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
     
}

struct DoCatchTryThrows: View {
    
    @StateObject private var viewModel = KeyWordsViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 200, height: 200)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}
