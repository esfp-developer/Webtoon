import Foundation

// MARK: - Network Error
public enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case invalidResponse
    case statusCode(Int)
    case decodingError(String)
    case networkError(String)
    case timeout
    case cancelled
}

// MARK: - Network Error Extensions
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noData:
            return "데이터를 불러올 수 없습니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .statusCode(let code):
            return "서버 오류 (코드: \(code))"
        case .decodingError(let message):
            return "데이터 파싱 오류: \(message)"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
}
