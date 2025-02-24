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
        .environment(worklogStore)
    }
        
    // TODO: Faire une liste de citation inspirantes sur l'imputation dans un JSON
    // TODO: Pouvoir charger les citations et les afficher aléatoirement
    // TODO: Remplacer le SFSymbol par une image de profil
    @ViewBuilder
    var inspiringQuoteView: some View {
        ZStack(alignment: .top) {
            HStack {
                Image("srivollet")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(Constants.inspiringQuotes.randomElement()!)
                    .italic()
                    .font(.caption)
                    .padding()
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

            }
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
    
    @State var issueID: String = ""
    
    @State var startDate: Date
    @State var endDate: Date

    init(recordedTime: LatestRecordedTime) {
        self._startDate = State(initialValue: recordedTime.startDate.addingTimeInterval(-2400))
        self._endDate = State(initialValue: recordedTime.endDate)
    }
    
    var canSave: Bool {
        !issueID.isEmpty && startDate < endDate
    }
    
    var body: some View {
        List {
            TextField("Project", text: $issueID, prompt: Text("PMI-2875..."))
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
                    Task {
                        await worklogStore.saveWorklog(startDate: startDate, endDate: endDate, issueID: issueID)
                        dismiss()
                    }
                }
                .disabled(!canSave)
            }
        }
    }
}

#Preview {
    ContentView()
}
