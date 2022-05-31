//
//  DownloadImageAsync.swift
//  Swift Concurrency
//
//  Created by Nizami Tagiyev on 31.05.2022.
//

import SwiftUI
import Combine

class AsyncImageLoader {
    
    let url =  URL(string: "https://picsum.photos/200")!
    
    func handleResponce(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300
        else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(complitionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponce(data: data, response: response)
            complitionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombime() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponce)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponce(data: data, response: response)
        } catch {
            throw error
        }
        
    }
}

class DownloadImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let loader = AsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        
        // MARK: @escaping closure
//        loader.downloadWithEscaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
        
        // MARK: Combine
//        loader.downloadWithCombime()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//
//            } receiveValue: { [weak self] returnedImage in
//                self?.image = returnedImage
//            }
//            .store(in: &cancellables)

        // MARK: Combine
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        // MARK: For @escaping and Combine
//        .onAppear {
//            viewModel.fetchImage()
//        }
        
        // MARK: For Async only
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
