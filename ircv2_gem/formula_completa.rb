#!/usr/bin/env ruby

# ICRv3.1 - FÓRMULA COMPLETA (amb pendent)
# Per usar quan el GPX té dades d'elevació (<ele>)

def calcular_icrv3_completa(angle:, radi:, amplada:, pendent_percent:)
  # 1. Pes base per angle
  pes_angle = (angle / 30.0) ** 2.0
  
  # 2. Factor radi (corbes tancades punten més)
  # R=15m → factor 8.6 | R=30m → 2.2 | R=50m → 1.0
  pes_radi = (50.0 / [radi, 15].max) ** 1.5
  
  # 3. Factor amplada (carreteres estretes són més difícils)
  f_amplada = case amplada
    when 0..4.5 then 1.25  # Pista/molt estreta
    when 4.5..5.5 then 1.15  # Estreta (PN.Garraf)
    when 5.5..6.5 then 1.10  # Mitjana
    when 6.5..8.0 then 1.0   # Normal
    else 0.9                 # Ampla
  end
  
  # 4. Factor pendent (pujada/baixada afegeix dificultat)
  # Pendent = desnivell (m) / distancia (m) × 100
  abs_pendent = pendent_percent.abs
  f_pendent = 1.0 + (abs_pendent / 100.0)  # +1% per cada 1% de pendent
  # Ex: 5% pendent → factor 1.05 | 10% → 1.10 | 15% → 1.15
  
  # Pes total d'aquesta corba
  pes_total = pes_angle * pes_radi * f_amplada * f_pendent
  
  {
    pes: pes_total,
    components: {
      angle: pes_angle.round(2),
      radi_factor: pes_radi.round(2),
      amplada: f_amplada,
      pendent: f_pendent.round(3)
    }
  }
end

puts "📊 ICRv3.1 - FÓRMULA COMPLETA"
puts "=" * 70
puts ""
puts "Components:"
puts "  ✓ Angle de deflexió (θ)"
puts "  ✓ Radi de curvatura (R)"  
puts "  ✓ Amplada de carretera (A)"
puts "  ✓ Pendent longitudinal (P%)"
puts ""
puts "-" * 70

# Exemples

ejemplos = [
  { nom: "Paella PN.Garraf (pujada)", angle: 160, radi: 25, amplada: 5.0, pendent: 8 },
  { nom: "Paella PN.Garraf (pla)", angle: 160, radi: 25, amplada: 5.0, pendent: 2 },
  { nom: "Paella en pista (baixada)", angle: 160, radi: 15, amplada: 4.0, pendent: -12 },
  { nom: "Corba ràpida C-road", angle: 45, radi: 80, amplada: 7.0, pendent: 0 },
]

ejemplos.each do |ex|
  resultat = calcular_icrv3_completa(
    angle: ex[:angle],
    radi: ex[:radi], 
    amplada: ex[:amplada],
    pendent_percent: ex[:pendent]
  )
  
  puts ""
  puts "🛣️  #{ex[:nom]}"
  puts "   Angle: #{ex[:angle]}° | Radi: #{ex[:radi]}m | Ample: #{ex[:amplada]}m | Pendent: #{ex[:pendent]}%"
  puts "   Pes total: #{resultat[:pes].round(1)}"
  puts "   Desglossat: #{resultat[:components]}"
end

puts ""
puts "=" * 70
puts ""
puts "💡 Impacte del pendent:"
puts "   Corba en pujada/baixada deu més que en pla"
puts "   Ex: Paella amb 8% pendent = +8% de pes"
puts ""
puts "📋 Per aplicar-ho al PN.Garraf:"
puts "   Necessito un GPX amb etiquetes <ele> amb valors"
puts "   (el track actual té <ele></ele> buides)"
puts ""
puts "🎯 Fórmula final:"
puts "   ICRv3 = Σ[(θ/30)² × (50/R)^1.5 × F_amplada × F_pendent]"
puts "   ICRv3 = (N_total / km) × Sinuositat² × 0.8"
puts "=" * 70
