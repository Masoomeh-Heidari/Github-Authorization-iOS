//
//  SearchService.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation


typealias searchRepositoryCallback = (( _ repositories: [Repository]?,_  nextPage: String?,
                                                                        _ error: SearchServiceError?) -> Void)

protocol SearchServiceProtocol {
        func search(by text:String, page: Int, callback:@escaping searchRepositoryCallback)
}


class SearchService:SearchServiceProtocol {
    
    let requestManager:RequestManagerProtocol
    let decoder = JSONDecoder()
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
    
    func search(by text:String, page: Int, callback:@escaping searchRepositoryCallback){
        requestManager.callAPI(requestConvertible: SearchRouter.searchRepo(query: text, page: page)) { (response, data, error) in
            var nextPage: String?
            var serviceError: SearchServiceError?
            var repositories: [Repository]?
            
            if let res = response {
                do {
                    if let link = try SearchService.parseNextURL(res) {
                        nextPage = SearchService.getNextPageFrom(url: link)
                    }
                } catch  {
                    serviceError = .unkownError
                }
            }
            
            if response?.statusCode == 403 {
                serviceError = .githubLimitReached
            }
            
            if let jsonData = data {
                do {
                    let searchResponse = try JSONDecoder().decode(SearchResponse<Repository>.self, from: jsonData)
                    repositories = searchResponse.items
                } catch {
                    serviceError = .unkownError
                }
            }
            
            
            callback(repositories , nextPage, serviceError)
            
        }
    }
}

extension SearchService {
    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.allowCommentsAndWhitespace])

    private static func parseLinks(_ links: String) throws -> [String: String] {

        let length = (links as NSString).length
        let matches = SearchService.linksRegex.matches(in: links, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: length))

        var result: [String: String] = [:]

        for m in matches {
            let matches = (1 ..< m.numberOfRanges).map { rangeIndex -> String in
                let range = m.range(at: rangeIndex)
                let startIndex = links.index(links.startIndex, offsetBy: range.location)
                let endIndex = links.index(links.startIndex, offsetBy: range.location + range.length)
                return String(links[startIndex ..< endIndex])
            }

            if matches.count != 2 {
                throw createError("Error parsing links")
            }

            result[matches[1]] = matches[0]
        }
        
        return result
    }

    private static func parseNextURL(_ httpResponse: HTTPURLResponse) throws -> URL? {
        guard let serializedLinks = httpResponse.allHeaderFields["Link"] as? String else {
            return nil
        }

        let links = try SearchService.parseLinks(serializedLinks)

        guard let nextPageURL = links["next"] else {
            return nil
        }

        guard let nextUrl = URL(string: nextPageURL) else {
            throw createError("Error parsing next url `\(nextPageURL)`")
        }

        return nextUrl
    }
    
    private static func getNextPageFrom(url : URL) -> String? {
        guard let params = url.absoluteURL.queryParameters, let page = params["page"] else{
            return nil
        }
        return page
    }
}
