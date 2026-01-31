import SwiftUI

struct AppColors {
    // ============================================
    // PALETTE BASE 🎨
    // Solo 3 colori dalla nuova palette!
    // ============================================
    
    /// 0F0F0F - Onyx ⬛ [Background]
    /// RGB: (15, 15, 15)
    static let onyx = Color(red: 15/255, green: 15/255, blue: 15/255)
    
    /// C41E3A - Intense Cherry 🍒 [Primary/Accent]
    /// RGB: (196, 30, 58)
    static let cherry = Color(red: 196/255, green: 30/255, blue: 58/255)
    
    /// EAEAEA - Alabaster Grey ⬜ [Text]
    /// RGB: (234, 234, 234)
    static let alabaster = Color(red: 234/255, green: 234/255, blue: 234/255)
    
    // ============================================
    // COLORI SEMANTICI 🎯
    // ============================================
    
    /// PRIMARIO - Intense Cherry 🍒
    /// Usa per: Bottoni principali, CTA, elementi chiave, azioni importanti
    static let primary = cherry  // #C41E3A 🍒
    
    /// SECONDARIO - Cherry più scuro
    /// Usa per: Elementi secondari, supporto, varianti
    static let secondary = Color(red: 160/255, green: 24/255, blue: 48/255)  // Cherry scuro
    
    /// ACCENT - Cherry più chiaro  
    /// Usa per: Accenti leggeri, highlights, dettagli
    static let accent = Color(red: 230/255, green: 57/255, blue: 86/255)  // Cherry chiaro
    
    /// SUCCESS - Verde per completamenti
    static let success = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    // ============================================
    // BACKGROUND 🖼️
    // ============================================
    
    /// Background principale app (Onyx nero)
    static let background = onyx  // #0F0F0F ⬛
    
    /// Background cards/elementi elevati (Onyx + 5%)
    static let cardBackground = Color(red: 26/255, green: 26/255, blue: 26/255)  // #1A1A1A
    
    /// Background ancora più elevato (Onyx + 10%)
    static let backgroundElevated = Color(red: 37/255, green: 37/255, blue: 37/255)  // #252525
    
    /// Background modali (Onyx base)
    static let backgroundModal = onyx
    
    // ============================================
    // TESTO 📝
    // ============================================
    
    /// Testo principale - Alabaster Grey ⬜
    static let textPrimary = alabaster  // #EAEAEA
    
    /// Testo secondario (grigio medio)
    static let textSecondary = Color(red: 153/255, green: 153/255, blue: 153/255)  // #999999
    
    /// Testo terziario (grigio scuro)
    static let textTertiary = Color(red: 102/255, green: 102/255, blue: 102/255)  // #666666
    
    // ============================================
    // STATUS COLORS 🚦
    // ============================================
    
    /// Errore, cancellazione ❌
    static let error = cherry  // 🍒 Cherry
    
    /// Warning, attenzione ⚠️
    static let warning = Color(red: 255/255, green: 152/255, blue: 0/255)  // Arancione
    
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
