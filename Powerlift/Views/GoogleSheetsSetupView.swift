import SwiftUI

struct GoogleSheetsSetupView: View {
    @ObservedObject var dataManager: DataManager
    @ObservedObject var sheetsSync: GoogleSheetsSync
    @State private var spreadsheetURL: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: sheetsSync.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(sheetsSync.isConnected ? .green : .red)
                        Text(sheetsSync.isConnected ? "Connesso" : "Non connesso")
                    }

                    if let lastSync = sheetsSync.lastSyncDate {
                        HStack {
                            Text("Ultima sincronizzazione")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Stato Connessione")
                }

                Section {
                    TextField("URL Google Sheets", text: $spreadsheetURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Button(action: {
                        sheetsSync.connectToSpreadsheet(url: spreadsheetURL)
                    }) {
                        HStack {
                            if sheetsSync.isLoading {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text("Connetti Spreadsheet")
                        }
                    }
                    .disabled(spreadsheetURL.isEmpty || sheetsSync.isLoading)
                } header: {
                    Text("Configura Spreadsheet")
                } footer: {
                    Text("Incolla l'URL completo del tuo Google Sheets.")
                }

                if sheetsSync.isConnected {
                    Section {
                        if let spreadsheetId = sheetsSync.spreadsheetId {
                            HStack {
                                Text("ID Spreadsheet")
                                Spacer()
                                Text(spreadsheetId.prefix(20) + "...")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }

                        Button(action: {
                            Task {
                                await sheetsSync.syncWorkoutPlans()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sincronizza Ora")
                            }
                        }
                        .disabled(sheetsSync.isLoading)

                        Button(role: .destructive) {
                            disconnectSpreadsheet()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Disconnetti")
                            }
                        }
                    } header: {
                        Text("Gestione")
                    }
                }

                if let error = sheetsSync.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    } header: {
                        Text("Errore")
                    }
                }
            }
            .navigationTitle("Google Sheets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let existingId = sheetsSync.spreadsheetId {
                    spreadsheetURL = "https://docs.google.com/spreadsheets/d/\(existingId)/edit"
                }
            }
        }
    }

    private func disconnectSpreadsheet() {
        sheetsSync.spreadsheetId = nil
        sheetsSync.isConnected = false
        spreadsheetURL = ""
        UserDefaults.standard.removeObject(forKey: "spreadsheetId")
    }
}

#Preview {
    GoogleSheetsSetupView(dataManager: DataManager(), sheetsSync: GoogleSheetsSync())
}
