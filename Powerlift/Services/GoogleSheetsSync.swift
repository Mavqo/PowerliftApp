import Foundation
import Combine

class GoogleSheetsSync: ObservableObject {
    @Published var isConnected = false
    @Published var lastSyncDate: Date?
    @Published var spreadsheetId: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Placeholder Methods
    
    func restoreSession() {
        // TODO: Implementare restore session
        if let id = UserDefaults.standard.string(forKey: "spreadsheetId") {
            spreadsheetId = id
            isConnected = !id.isEmpty
        }
    }
    
    func syncWorkoutPlans() async -> [WorkoutPlan] {
        // TODO: Implementare sync da Google Sheets
        // Per ora ritorna array vuoto
        return []
    }
    
    func signInWithGoogle() async {
        // TODO: Implementare Google Sign In
    }
    
    func connectToSpreadsheet(url: String) {
        // TODO: Implementare connessione spreadsheet
        if let id = extractSpreadsheetId(from: url) {
            spreadsheetId = id
            isConnected = true
            UserDefaults.standard.set(id, forKey: "spreadsheetId")
        }
    }
    
    private func extractSpreadsheetId(from url: String) -> String? {
        let pattern = "/spreadsheets/d/([a-zA-Z0-9-_]+)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
            if let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }
}
