import Foundation
import ComposableArchitecture

// MARK: - Network Client Protocol
public protocol NetworkClientProtocol {
    func execute<T: NetworkRequest>(_ request: T) async throws -> T.ResponseType
}

// MARK: - Network Client (Alamofire 기반)
public struct NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
        
        // Date decoding strategy 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    public func execute<T: NetworkRequest>(_ request: T) async throws -> T.ResponseType {
        guard let url = URL(string: request.fullURL) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout
        
        // Headers 설정
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Body 설정
        if let body = request.body {
            urlRequest.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Status code 확인
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }
            
            // 응답 데이터가 없는 경우
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            // JSON 디코딩
            do {
                let result = try decoder.decode(T.ResponseType.self, from: data)
                return result
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw NetworkError.timeout
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.networkError(error.localizedDescription)
            }
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
    }
}
