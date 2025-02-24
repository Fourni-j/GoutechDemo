//
//  ContentView.swift
//  Imputabot-ios
//
//  Created by Charles Fournier on 22/02/2025.
//

import SwiftUI

struct LatestRecordedTime: Identifiable {
    var id: UUID
    var startDate: Date
    var endDate: Date
}

@Observable class WorklogStore {
    var isTimerRunning = false
    var startTime: Date?
    private var timer: Timer?
    var elapsedTime: TimeInterval = 0
    
//    var presentWorkogSheet = false
    var latestRecordedTime: LatestRecordedTime?
    
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
//            presentWorkogSheet = true
        }
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedTime = 0
    }
    
    func saveWorklog() {
        print("Send worklog to jira work log")
    }
}

struct ContentView: View {
    @State var worklogStore = WorklogStore()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("IMPUTABOT")
                .font(.title)
                .fontDesign(.rounded)
                .bold()
            inspiringQuoteView
            Spacer()
            if worklogStore.isTimerRunning {
                runningTimerView
            } else {
                startButton
            }
            Spacer()
            latestImputationView
        }
        .padding()
        .sheet(item: $worklogStore.latestRecordedTime) { recordedTime in
            NavigationStack {
                WorkogSheetView(recordedTime: recordedTime)
            }
        }
//        .sheet(isPresented: $worklogStore.presentWorkogSheet) {
//            NavigationStack {
//                WorkogSheetView()
//            }
//        }
        .environment(worklogStore)
    }
        
    // TODO: Faire une liste de citation inspirantes sur l'imputation dans un JSON
    // TODO: Pouvoir charger les citations et les afficher aléatoirement
    // TODO: Remplacer le SFSymbol par une image de profil
    @ViewBuilder
    var inspiringQuoteView: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
            Text("Imputer ses heures au fil de l'eau, c'est comme ranger un peu chaque jour: ça prend deux minutes et ça évite le chaos du vendredi soir")
                .italic()
                .font(.caption)
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // TODO: Rendre le bouton un peu plus joli
    @ViewBuilder
    var startButton: some View {
        Button {
            worklogStore.startTimer()
        } label: {
            VStack {
                Text("START")
                Text("TIMER")
            }
            .frame(maxWidth: .infinity)
            .fontWeight(.heavy)
            .foregroundStyle(.black)
            .padding()
            .background(.green.gradient.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var runningTimerView: some View {
        VStack {
            let hours = Int(worklogStore.elapsedTime) / 3600
            let minutes = Int(worklogStore.elapsedTime) / 60 % 60
            let seconds = Int(worklogStore.elapsedTime) % 60
            Text(String(format: "%02dh%02dm%02ds", hours, minutes, seconds))
                .font(.title)
                .bold()
                .contentTransition(.numericText())
                .monospacedDigit()
        }
        .padding()
        .background(.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            worklogStore.stopTimer()
        }
    }
    
    //TODO: Récupérer les données de la dernière imputation
    //TODO: Placeholder si pas de dernière
    @ViewBuilder
    var latestImputationView: some View {
        VStack {
            Text("Dernière imputation")
                .frame(maxWidth: .infinity)
                .bold()
            HStack {
                Image(systemName: "calendar")
                Text("12/02/2025")
            }
            HStack {
                Image(systemName: "clock")
                Text("2h30")
            }
            HStack {
                Image(systemName: "pencil")
                Text("Développement")
            }
        }
        .padding()
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


struct WorkogSheetView: View {
    @Environment(WorklogStore.self) var worklogStore
    @Environment(\.dismiss) var dismiss
    
    @State var ticketName: String = ""
    
    @State var startDate: Date
    @State var endDate: Date

    init(recordedTime: LatestRecordedTime) {
        self._startDate = State(initialValue: recordedTime.startDate.addingTimeInterval(-2400))
        self._endDate = State(initialValue: recordedTime.endDate)
    }
    
    var canSave: Bool {
        !ticketName.isEmpty && startDate < endDate
    }
    
    var body: some View {
        List {
            TextField("Project", text: $ticketName, prompt: Text("PMI-2875..."))
                .autocorrectionDisabled()
            
            if let recordedTime = worklogStore.latestRecordedTime {
                DatePicker("Start date", selection: $startDate, displayedComponents: .date.union(.hourAndMinute))
                DatePicker("End date", selection: $endDate, displayedComponents: .date.union(.hourAndMinute))
            }
            
            let timeInterval = endDate.timeIntervalSince(startDate)
            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) / 60 % 60
            LabeledContent("Elapsed time", value: String(format: "%dh%02dm", hours, minutes))
                .monospacedDigit()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    worklogStore.saveWorklog()
                }
                .disabled(!canSave)
            }
        }
    }
}

#Preview {
    ContentView()
}
