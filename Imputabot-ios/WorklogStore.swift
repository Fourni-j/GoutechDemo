//
//  WorklogStore.swift
//  Imputabot-ios
//
//  Created by Charles Fournier on 24/02/2025.
//

import SwiftUI

@Observable class WorklogStore {
    var isTimerRunning = false
    var startTime: Date?
    private var timer: Timer?
    var elapsedTime: TimeInterval = 0
    
    var latestRecordedTime: LatestRecordedTime?
        
    let jiraService = JiraService()
    
    func startTimer() {
        startTime = Date()
        withAnimation {
            isTimerRunning = true
        }
        
        // Create a timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            withAnimation {
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    func stopTimer() {
        withAnimation {
            isTimerRunning = false
        }
        if let startTime = startTime {
            latestRecordedTime = LatestRecordedTime(id: UUID(), startDate: startTime, endDate: Date())
        }
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedTime = 0
    }
    
    func saveWorklog(startDate: Date, endDate: Date, issueID: String) async {
        do {
            let timeInterval = endDate.timeIntervalSince(startDate)
            let request = jiraService.jiraWorklogRequest(startDate: startDate, computedDuration: Int(timeInterval), issueID: issueID)
            let result = try await URLSession.shared.data(for: request)
            print(result)
        } catch {
            print(error)
        }
    }
}
