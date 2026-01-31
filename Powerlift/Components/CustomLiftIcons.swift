import SwiftUI

// MARK: - Custom Powerlifting Icons
// Icone custom per Squat, Bench Press, Deadlift

struct SquatIcon: View {
    var color: Color = .white
    var size: CGFloat = 32
    
    var body: some View {
        ZStack {
            // Bilanciere
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 1.2, height: size * 0.08)
                .offset(y: -size * 0.35)
            
            // Pesi sinistra
            Circle()
                .fill(color)
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(x: -size * 0.55, y: -size * 0.35)
            
            // Pesi destra
            Circle()
                .fill(color)
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(x: size * 0.55, y: -size * 0.35)
            
            // Testa
            Circle()
                .fill(color)
                .frame(width: size * 0.25, height: size * 0.25)
                .offset(y: -size * 0.1)
            
            // Corpo (accovacciato)
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(color)
                .frame(width: size * 0.2, height: size * 0.35)
                .offset(y: size * 0.2)
            
            // Gambe (piegate)
            // Gamba sinistra
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 0.12, height: size * 0.3)
                .rotationEffect(.degrees(-25))
                .offset(x: -size * 0.15, y: size * 0.45)
            
            // Gamba destra
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 0.12, height: size * 0.3)
                .rotationEffect(.degrees(25))
                .offset(x: size * 0.15, y: size * 0.45)
        }
        .frame(width: size * 1.4, height: size * 1.4)
    }
}

struct BenchPressIcon: View {
    var color: Color = .white
    var size: CGFloat = 32
    
    var body: some View {
        ZStack {
            // Bilanciere (sopra)
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 1.0, height: size * 0.08)
                .offset(y: -size * 0.4)
            
            // Pesi sinistra
            RoundedRectangle(cornerRadius: size * 0.03)
                .fill(color)
                .frame(width: size * 0.12, height: size * 0.18)
                .offset(x: -size * 0.5, y: -size * 0.4)
            
            // Pesi destra
            RoundedRectangle(cornerRadius: size * 0.03)
                .fill(color)
                .frame(width: size * 0.12, height: size * 0.18)
                .offset(x: size * 0.5, y: -size * 0.4)
            
            // Testa (sdraiata)
            Circle()
                .fill(color)
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(x: -size * 0.25, y: -size * 0.05)
            
            // Corpo (sdraiato sulla panca)
            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(color)
                .frame(width: size * 0.5, height: size * 0.18)
                .offset(y: -size * 0.05)
            
            // Braccia (che spingono)
            // Braccio sinistro
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(color)
                .frame(width: size * 0.08, height: size * 0.28)
                .rotationEffect(.degrees(-10))
                .offset(x: -size * 0.15, y: -size * 0.25)
            
            // Braccio destro
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(color)
                .frame(width: size * 0.08, height: size * 0.28)
                .rotationEffect(.degrees(10))
                .offset(x: size * 0.15, y: -size * 0.25)
            
            // Panca (base)
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color.opacity(0.6))
                .frame(width: size * 0.6, height: size * 0.1)
                .offset(y: size * 0.15)
            
            // Gambe
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(color)
                .frame(width: size * 0.1, height: size * 0.25)
                .offset(x: size * 0.35, y: size * 0.3)
        }
        .frame(width: size * 1.4, height: size * 1.2)
    }
}

struct DeadliftIcon: View {
    var color: Color = .white
    var size: CGFloat = 32
    
    var body: some View {
        ZStack {
            // Bilanciere (in basso)
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 1.1, height: size * 0.08)
                .offset(y: size * 0.45)
            
            // Pesi sinistra
            Circle()
                .fill(color)
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: -size * 0.52, y: size * 0.45)
            
            // Pesi destra
            Circle()
                .fill(color)
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: size * 0.52, y: size * 0.45)
            
            // Testa
            Circle()
                .fill(color)
                .frame(width: size * 0.24, height: size * 0.24)
                .offset(y: -size * 0.35)
            
            // Corpo (piegato in avanti)
            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(color)
                .frame(width: size * 0.18, height: size * 0.45)
                .rotationEffect(.degrees(20))
                .offset(x: size * 0.05, y: -size * 0.05)
            
            // Braccia (che afferrano)
            // Braccio sinistro
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(color)
                .frame(width: size * 0.08, height: size * 0.35)
                .rotationEffect(.degrees(5))
                .offset(x: -size * 0.1, y: size * 0.2)
            
            // Braccio destro
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(color)
                .frame(width: size * 0.08, height: size * 0.35)
                .rotationEffect(.degrees(-5))
                .offset(x: size * 0.1, y: size * 0.2)
            
            // Gambe (leggermente piegate)
            // Gamba sinistra
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 0.12, height: size * 0.4)
                .rotationEffect(.degrees(-8))
                .offset(x: -size * 0.08, y: size * 0.25)
            
            // Gamba destra
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(color)
                .frame(width: size * 0.12, height: size * 0.4)
                .rotationEffect(.degrees(8))
                .offset(x: size * 0.08, y: size * 0.25)
        }
        .frame(width: size * 1.4, height: size * 1.4)
    }
}

// MARK: - Preview
struct CustomLiftIcons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            HStack(spacing: 40) {
                VStack {
                    SquatIcon(color: .red, size: 50)
                    Text("Squat")
                        .foregroundColor(.white)
                }
                
                VStack {
                    BenchPressIcon(color: .blue, size: 50)
                    Text("Bench Press")
                        .foregroundColor(.white)
                }
                
                VStack {
                    DeadliftIcon(color: .green, size: 50)
                    Text("Deadlift")
                        .foregroundColor(.white)
                }
            }
            
            // Versioni piccole
            HStack(spacing: 30) {
                SquatIcon(color: .red, size: 32)
                BenchPressIcon(color: .blue, size: 32)
                DeadliftIcon(color: .green, size: 32)
            }
        }
        .padding()
        .background(Color.black)
    }
}
