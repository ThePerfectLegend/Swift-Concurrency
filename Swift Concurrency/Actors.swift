//
//  Actors.swift
//  Swift Concurrency
//
//  Created by Nizami Tagiyev on 09.07.2022.
//

import SwiftUI


class DataManager {
    
    static let inctance = DataManager()
    private init() { }
    
    var data: [String] = []
    private let queue = DispatchQueue(label: "com.DataManager")
    
    func getRandomData(complitionHandler: @escaping (_ title: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            complitionHandler(self.data.randomElement())
        }
    }
}

actor ActorDataManager {
    
    static let inctance = ActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    /// Dont need  to use await
    nonisolated func getSavedData() -> String {
        return "Some New Data"
    }
}

// MARK: Using with DataManager with created separated DispatchQueue
//struct HomeView: View {
//
//    let manager = DataManager.inctance
//    @State private var text: String = ""
//    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
//
//    var body: some View {
//        ZStack {
//            Color.gray
//                .opacity(0.8)
//                .ignoresSafeArea()
//            Text(text)
//                .font(.headline)
//        }
//        .onReceive(timer) { _ in
//            DispatchQueue.global().async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

struct HomeView: View {
    
    let manager = ActorDataManager.inctance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.8)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
            let newString = manager.getSavedData()
        })
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct BrowseView: View {
    
    let manager = ActorDataManager.inctance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow
                .opacity(0.8)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct Actors: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}
