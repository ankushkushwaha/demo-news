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
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as NewsServiceError {
#if DEBUG
            print(error)
#endif
            throw mapToRepositoryError(error)
        } catch {
            throw NewsRepositoryError.unknown(error)
        }
    }
    
    private func mapToRepositoryError(_ error: NewsServiceError) -> NewsRepositoryError {
            switch error {
            case .invalidUrl, .clientError:
                return .invalidRequest
            case .invalidResponse, . networkFailure:
                return .networkFailure
            case .notFound:
                return .notFound
            case .serverError(let code):
                return .serverError(code)
            case .timeout:
                return .timeout
            case .unknown(let error):
                return .unknown(error)
            }
        }
}


enum NewsRepositoryError: Error, LocalizedError {
    case invalidRequest
    case networkFailure
    case timeout
    case notFound
    case serverError(Int)
    case unknown(Error)
        
    var message: String {
        switch self {
        case .invalidRequest:
            return "Invalid request. Please try again."
        case .networkFailure:
            return "Network unavailable. Check your connection."
        case .timeout:
            return "Request timed out. Please try again."
        case .notFound:
            return "No news found."
        case .serverError(let code):
            return "Server error (\(code)). Try again later."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
