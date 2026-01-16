import SwiftUI

struct AppColors {
    // ============================================
    // PALETTE BASE (colori RAW) 🎨
    // Priorità: SINISTRA → DESTRA (più → meno importante)
    // ============================================
    
    /// 0F0F0F - Onyx ⬛ [BASE - Background]
    static let onyx = Color(red: 0.06, green: 0.06, blue: 0.06)      // #0F0F0F
    
    /// C41E3A - Intense Cherry 🍒 [PRIORITÀ 1 - PIÙ IMPORTANTE!]
    static let cherry = Color(red: 0.77, green: 0.12, blue: 0.23)    // #C41E3A
    
    /// EAEAEA - Alabaster Grey ⬜ [PRIORITÀ 2 - Testo]
    static let alabaster = Color(red: 0.92, green: 0.92, blue: 0.92) // #EAEAEA
    
    /// AF764B - Cinnamon Wood 🤎 [PRIORITÀ 3]
    static let cinnamon = Color(red: 0.69, green: 0.46, blue: 0.29)  // #AF764B
    
    /// D99878 - Toasted Almond 🧡 [PRIORITÀ 4 - Meno importante]
    static let almond = Color(red: 0.85, green: 0.60, blue: 0.47)    // #D99878
    
    // ============================================
    // COLORI SEMANTICI (priorità sinistra→destra) 🎯
    // ============================================
    
    /// PRIMARIO - Intense Cherry 🍒 (PIÙ IMPORTANTE!)
    /// Usa per: Bottoni principali, CTA, elementi chiave, azioni importanti
    static let primary = cherry  // #C41E3A 🍒
    
    /// SECONDARIO - Cinnamon Wood 🤎
    /// Usa per: Elementi secondari, supporto, varianti
    static let secondary = cinnamon  // #AF764B 🤎
    
    /// ACCENT - Toasted Almond 🧡
    /// Usa per: Accenti leggeri, highlights, dettagli
    static let accent = almond  // #D99878 🧡
    
    // ============================================
    // BACKGROUND 🖼️
    // ============================================
    
    /// Background principale app (Onyx nero)
    static let background = onyx  // #0F0F0F ⬛
    
    /// Background cards/elementi elevati
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    /// Background ancora più elevato
    static let backgroundElevated = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    /// Background modali
    static let backgroundModal = Color(red: 0.10, green: 0.10, blue: 0.10)
    
    // ============================================
    // TESTO 📝
    // ============================================
    
    /// Testo principale - Alabaster Grey
    static let textPrimary = alabaster  // #EAEAEA ⬜
    
    /// Testo secondario (grigio medio)
    static let textSecondary = Color(red: 0.60, green: 0.60, blue: 0.60)
    
    /// Testo terziario (grigio scuro)
    static let textTertiary = Color(red: 0.40, green: 0.40, blue: 0.40)
    
    // ============================================
    // STATUS COLORS 🚦
    // ============================================
    
    /// Successo, completamento ✅
    static let success = cherry  // 🍒 Cherry (rosso positivo!)
    
    /// Errore, cancellazione ❌
    static let error = cherry  // 🍒 Cherry
    
    /// Warning, attenzione ⚠️
    static let warning = cinnamon  // 🤎 Cinnamon
    
    // ============================================
    // STATS COLORS 📊
    // ============================================
    
    /// Velocità - Cherry (importante!)
    static let statVelocity = cherry  // 🍒
    
    /// Potenza - Cinnamon
    static let statPower = cinnamon  // 🤎
    
    /// ROM - Almond
    static let statROM = almond  // 🧡
    
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
