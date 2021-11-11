//
//  M3u8Parser.swift
//  VODPlayground
//
//  Created by Yousef on 9/28/21.
//

import Foundation

struct Resolution: Identifiable {
    let id = UUID().uuidString
    
    let degree: String
    let path: String
    
    init(_ text: String) {
        let components = text.components(separatedBy: "\n")
        let first = (components[0].components(separatedBy: "x"))[1]
        self.degree = first
        self.path = components[1]
    }
}

struct MovieDetails {
    let storageUrl: String
    let srtPath: String
    let streamPath: String
    let srtFile: String
    let streamFile: String
    var resolutions: [Resolution]
}

class M3u8Parser {
    static func getResolutions() -> Result<[Resolution], M3u8ParserError> {
        
        
        let urlString = URLS.storageUrl + URLS.streamPath + URLS.streamFile
        print(#function, urlString)
        
        guard let url = Bundle.main.url(forResource: "example", withExtension: "m3u8") else {
            print("🔥 Can't read Content")
            return .failure(.invalidURL)
            
        }
        
        
//        let urlString = URLS.baseURL + URLS.streamPath + URLS.streamFile
//        guard let url = URL(fileURLWithPath: urlString) else {
//            print("🔥 Can't read path")
//            return "🔥 Can't read path"
//        }
//        let text = String(data: data, encoding: .utf8) ?? "🔥 Can't convert data to string"
//        return "\(urlString)\r\n\(text)"
        
        
        guard var text = try? String(contentsOf: url) else {
            print("🔥 Can't read Content")
            return .failure(.badContent)
        }
        
        text = text.components(separatedBy: .newlines).joined(separator: "\n")
        
        do {
            
            let expression = "[0-9]+x[0-9]+\\n(...*)m3u8"
            let regex = try NSRegularExpression(pattern: expression)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            
            
            let result = matches.map({Resolution(String(text[Range($0.range, in: text)!]))})
            
            result.forEach({print($0.degree, $0.path)})
            return .success(result)
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return .failure(.invalidRegex(error.localizedDescription))
        }
        
        
    }
    
    
    static func ResolutionsAsync(url: URL, complition: @escaping (Result<[VPResolution], M3u8ParserError>) -> Void) {
        
        guard var text = try? String(contentsOf: url) else {
            complition(.failure(M3u8ParserError.badContent))
            return
        }
        
        text = text.components(separatedBy: .newlines).joined(separator: "\n")
        
        do {
            
            let expression = "[0-9]+x[0-9]+(...*)\\n(...*)m3u8"
            let regex = try NSRegularExpression(pattern: expression)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            
            let returned = matches.map({VPResolution(String(text[Range($0.range, in: text)!]))})
            
            let all = returned.compactMap({$0})
            
            var result = [VPResolution]()
            result.append(VPResolution(bandWidth: 0, title: "Auto", URI: url.absoluteString))
            all.forEach { res in
                if result.first(where: {$0.title == res.title}) == nil {
                    result.append(res)
                }
            }
            
            /*
             1080
             720
             432
             */
//            result.forEach({print($0.title)})
//            result = Array(result.prefix(4))
            
            var endResult = [VPResolution]()
            result.forEach({item in
                if item.title == "Auto" || item.title == "1080" || item.title == "720" || item.title == "432" {
                    endResult.append(item)
                }
            })
            
            endResult.forEach({print($0.title)})
            
            complition(.success(endResult))
        } catch let error {
            complition(.failure(.invalidRegex(error.localizedDescription)))
        }
        
    }
    
    static func getAppleResolutions(url: URL) -> [VPResolution] {
        
        guard var text = try? String(contentsOf: url) else {
            print("🔥 Can't read Content")
            return []
        }
        
        text = text.components(separatedBy: .newlines).joined(separator: "\n")
        
        do {
            
            let expression = "[0-9]+x[0-9]+(...*)\\n(...*)m3u8"
            let regex = try NSRegularExpression(pattern: expression)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            
            let returned = matches.map({VPResolution(String(text[Range($0.range, in: text)!]))})
            
            let all = returned.compactMap({$0})
            
            var result = [VPResolution]()
            result.append(VPResolution(bandWidth: 0, title: "Auto", URI: url.absoluteString))
            all.forEach { res in
                if result.first(where: {$0.title == res.title}) == nil {
                    result.append(res)
                }
            }
            
            result = Array(result.prefix(4))
            result.forEach({print($0.title)})
            return result
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
        
        
    }
    
    func getContent() -> String {
        guard let url = Bundle.main.url(forResource: "example", withExtension: "m3u8") else {
            print("🔥 Invalid URL")
            return "🔥 Invalid URL"
            
        }
        
        guard let text = try? String(contentsOf: url) else {
            print("🔥 Can't read Content")
            return "🔥 Can't read Content"
        }
        
        return text
    }
    
    static func baseURL(_ url: URL) -> String {

        
        let urlString = url.absoluteString
        let filename = (urlString.components(separatedBy: "/")).last!
        let result = urlString.replacingOccurrences(of: filename, with: "")
        
        return result
    }
    
    func fileName() -> String {
        let url = "https://cdn01.scopesky.iq/share/uploads/movies/file/25831__e6c79a308e2590cb5dee39054a5b2334d371ccf65f37d936654484bc2ebaf16e_1632645366/25831__e6c79a308e2590cb5dee39054a5b2334d371ccf65f37d936654484bc2ebaf16e_1632645366.m3u8"
        let filename = (url.components(separatedBy: "/")).last!
        
        return filename
    }
    
}

extension M3u8Parser {
    enum URLS {
        static let storageUrl = "https://cdn01.scopesky.iq"
        static let srtPath = "/share/uploads/movies/srt/"
        static let streamPath = "/share/uploads/movies/file/25831__e6c79a308e2590cb5dee39054a5b2334d371ccf65f37d936654484bc2ebaf16e_1632645366/"
        
        
        static let srtFile = "f7c1fc1a05e9bb35f23aa67131b1e7329f045849d6a937255a8cad13d9a1433c_1632644458.srt"
        static let streamFile = "25831__e6c79a308e2590cb5dee39054a5b2334d371ccf65f37d936654484bc2ebaf16e_1632645366.m3u8"
        
        
        static let imageName = "80e7604ec487d22934c24fd93eb0afc0613d1ea00010a15c31851957f606ead1_1632386214.jpg"
        static let imagePath = "/share/uploads/movies/imgs/"
    }
    
    enum M3u8ParserError: Error, LocalizedError {
        case invalidURL
        case badContent
        case invalidRegex(String)
        
        var errorDescription: String? {
            switch self {
            
            case .invalidURL:
                return "Please check your URL again"
            case .badContent:
                return "Can't read the content of the file"
            case .invalidRegex(let error):
                return error
            }
        }
    }
}
