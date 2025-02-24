//
//  JiraService.swift
//  Imputabot-ios
//
//  Created by Charles Fournier on 24/02/2025.
//

import Foundation

class JiraService {
    
    struct WorkLogEntry: Codable {
        let started: String
        let timeSpentSeconds: Int
        let author: WorkLogAuthor
    }

    struct WorkLogAuthor: Codable {
        let accountId: String
    }

    
    func jiraWorklogRequest(startDate: Date, computedDuration: Int, issueID: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://praxedo.atlassian.net/rest/api/2/issue/\(issueID)/worklog?adjustEstimate=new&newEstimate=0m&_r=1650443841")!)
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("com.jiraworkcalendar.work-calendar", forHTTPHeaderField: "ap-client-key")
        request.addValue(Constants.cookies, forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "POST"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ss.SSSZ"
        let dateString = formatter.string(from: startDate)
        let workLogEntry = WorkLogEntry(started: dateString, timeSpentSeconds: computedDuration, author: WorkLogAuthor(accountId: Constants.authorId))
        request.httpBody = try? JSONEncoder().encode(workLogEntry)
        
        return request
    }
    



}
