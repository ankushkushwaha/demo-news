import Foundation

protocol NewsRepository {
    func fetchNews(query: NewsQuery) async throws -> [NewsItem]
}

final class NewsRepositoryImpl: NewsRepository {
    private let service: NewsService
    
    init(service: NewsService = NewsServiceImpl()) {
        self.service = service
    }
    
    func fetchNews(query: NewsQuery) async throws -> [NewsItem] {
        do {
            let dtos = try await service.fetchNews(query: query)
            return dtos.map { $0.toNewsItem() }
        } catch let error as NewsServiceError {
#if DEBUG
            print(error)
#endif
            throw mapToRepositoryError(error)
        } catch {
            throw NewsRepositoryError.unknown(error)
        }
    }
    
    func mapToRepositoryError(_ error: NewsServiceError) -> NewsRepositoryError {
        switch error {
        case .invalidUrl:
            return .invalidRequest
        case .invalidResponse:
            return .networkFailure
        case .httpError(let code):
            return .serverError(code)
        }
    }
    
}

enum NewsRepositoryError: Error, LocalizedError {
    case invalidRequest
    case networkFailure
    case serverError(Int)
    case unknown(Error)

    var messsage: String {
        switch self {
        case .invalidRequest: 
            return "Invalid request. Please try again."
        case .networkFailure:  
            return "Network unavailable. Check your connection."
        case .serverError(let code): 
            return "Server error (\(code)). Try again later."
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}
