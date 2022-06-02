//
//  AsyncAwait.swift
//  Swift Concurrency
//
//  Created by Nizami Tagiyev on 02.06.2022.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    // MARK: DispatchQueue
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dataArray.append("Title1: \(Thread.current)")

        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let title = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }

        }
    }
    
    // MARK: Async/Await
    
    func addAuthor() async {
        let author1 = "Author1: \(Thread.current)" // <- main
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2: \(Thread.current)" // <- background
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3: \(Thread.current)" // <- main
            self.dataArray.append(author3)
        })
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1 = "something1: \(Thread.current)" // <- background
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "something2: \(Thread.current)" // <- main
            self.dataArray.append(something2)
        })
    }
    
}

struct AsyncAwait: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor()
                await viewModel.addSomething()
            }
            // MARK: DispatchQueue
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}
