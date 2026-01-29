import SwiftUI

struct MainView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(dataManager: dataManager)
                    .tag(0)
                
                WorkoutPlannerView(dataManager: dataManager)
                    .tag(1)
                
                Color.clear
                    .tag(2)
                
                ProgressView(dataManager: dataManager)
                    .tag(3)
                
                ProfileView(dataManager: dataManager)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            CustomTabBar(selectedTab: $selectedTab, dataManager: dataManager)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var dataManager: DataManager
    @State private var showingCamera = false
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarButton(
                icon: "calendar",
                title: "Workout",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            Button(action: {
                showingCamera = true
            }) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 60, height: 60)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -15)
            .sheet(isPresented: $showingCamera) {
                CameraPlaceholderView(dataManager: dataManager)
            }
            
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "Progress",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            TabBarButton(
                icon: "person.fill",
                title: "Profilo",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            AppColors.backgroundElevated
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct CameraPlaceholderView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack {
                    Text("Camera")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Coming Soon")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Chiudi") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}
