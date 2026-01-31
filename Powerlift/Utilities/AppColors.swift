import SwiftUI

struct AppColors {
    // ============================================
    // PALETTE BASE 🎨
    // Solo 3 colori dalla nuova palette!
    // ============================================
    
    /// 0F0F0F - Onyx ⬛ [Background]
    static let onyx = Color(hex: "0F0F0F")
    
    /// C41E3A - Intense Cherry 🍒 [Primary/Accent]
    static let cherry = Color(hex: "C41E3A")
    
    /// EAEAEA - Alabaster Grey ⬜ [Text]
    static let alabaster = Color(hex: "EAEAEA")
    
    // ============================================
    // COLORI SEMANTICI 🎯
    // ============================================
    
    /// PRIMARIO - Intense Cherry 🍒
    /// Usa per: Bottoni principali, CTA, elementi chiave, azioni importanti
    static let primary = cherry  // #C41E3A 🍒
    
    /// SECONDARIO - Cherry più scuro
    /// Usa per: Elementi secondari, supporto, varianti
    static let secondary = Color(hex: "A01830")  // Cherry scuro
    
    /// ACCENT - Cherry più chiaro
    /// Usa per: Accenti leggeri, highlights, dettagli
    static let accent = Color(hex: "E63956")  // Cherry chiaro
    
    /// SUCCESS - Verde derivato da Cherry
    static let success = Color(hex: "4CAF50")  // Verde per completamenti
    
    // ============================================
    // BACKGROUND 🖼️
    // ============================================
    
    /// Background principale app (Onyx nero)
    static let background = onyx  // #0F0F0F ⬛
    
    /// Background cards/elementi elevati (Onyx + 5%)
    static let cardBackground = Color(hex: "1A1A1A")  // Onyx più chiaro
    
    /// Background ancora più elevato (Onyx + 10%)
    static let backgroundElevated = Color(hex: "252525")  // Onyx ancora più chiaro
    
    /// Background modali (Onyx base)
    static let backgroundModal = onyx
    
    // ============================================
    // TESTO 📝
    // ============================================
    
    /// Testo principale - Alabaster Grey ⬜
    static let textPrimary = alabaster  // #EAEAEA
    
    /// Testo secondario (Alabaster più scuro)
    static let textSecondary = Color(hex: "999999")  // Grigio medio
    
    /// Testo terziario (Alabaster ancora più scuro)
    static let textTertiary = Color(hex: "666666")  // Grigio scuro
    
    // ============================================
    // STATUS COLORS 🚦
    // ============================================
    
    /// Errore, cancellazione ❌
    static let error = cherry  // 🍒 Cherry
    
    /// Warning, attenzione ⚠️
    static let warning = Color(hex: "FF9800")  // Arancione
    
    // ============================================
    // STATS COLORS 📊
    // ============================================
    
    /// Velocità - Cherry
    static let statVelocity = cherry  // 🍒
    
    /// Potenza - Cherry scuro
    static let statPower = secondary
    
    /// ROM - Cherry chiaro
    static let statROM = accent
    
    // ============================================
    // OVERLAY & BORDERS 🎭
    // ============================================
    
    /// Overlay medio
    static let overlayMedium = Color.black.opacity(0.5)
    
    /// Overlay leggero
    static let overlayLight = Color.black.opacity(0.3)
    
    /// Overlay pesante
    static let overlayHeavy = Color.black.opacity(0.7)
    
    /// Bordi attivi
    static let borderActive = alabaster.opacity(0.3)
    
    /// Bordi inattivi
    static let borderInactive = Color.white.opacity(0.1)
}

// MARK: - Color Extension per HEX
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
