import SwiftUI

// Questo file non è più necessario
// Abbiamo già DashboardView che fa tutto

// Se vuoi mantenerlo come placeholder:
struct HomeView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        Text("HomeView non più utilizzato")
            .foregroundColor(AppColors.textPrimary)
    }
}
