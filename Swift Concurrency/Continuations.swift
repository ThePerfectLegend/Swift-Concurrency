//
//  Continuations.swift
//  Swift Concurrency
//
//  Created by Nizami Tagiyev on 06.06.2022.
//

import SwiftUI

class ContinuationsNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, responce, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDB(complitionHandler: @escaping (_ image: UIImage) -> Void ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            complitionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func hetHeartImageSFSimbol() async -> UIImage {
       return await withCheckedContinuation { continuation in
            getHeartImageFromDB { image in
                continuation.resume(returning: image)
            }
        }
    }
    
}

class ContinuationsViewModel: ObservableObject {
    
    @Published var image: UIImage?
    let networkManager = ContinuationsNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
           let data =  try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() async {
        self.image = await networkManager.hetHeartImageSFSimbol()
    }
    
}

struct Continuations: View {
    
    @StateObject private var viewModel = ContinuationsViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}
