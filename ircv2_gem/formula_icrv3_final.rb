#!/usr/bin/env ruby

# ICRv3 - VERSIÓ FINAL SIMPLIFICADA
# Components: Angle + Radi + Tipus de Carretera (N/P/L)

def calcular_icrv3(angle:, radi:, tipus_carretera:)
  # 1. Pes per angle (quadràtic)
  pes_angle = (angle / 30.0) ** 2.0
  
  # 2. Pes per radi (exponencial 1.5)
  # R=15m → 8.6 | R=25m → 4.0 | R=50m → 1.0 | R=80m → 0.5
  pes_radi = (50.0 / [radi, 10].max) ** 1.5
  
  # 3. Factor per tipus de carretera (amplada + dificultat típica)
  f_carretera = case tipus_carretera
    when :local, :L     # Carretera local, pista, BV, TV
      1.4               # Molt estreta, molt revirada
    when :provincial, :P, :comarcal  # C-roads, carreteres comarcals
      1.15              # Mitjana, corbes regulars
    when :nacional, :N  # Carreteres nacionals principals
      0.9               # Ampla, corbes suaus
    else
      1.0
  end
  
  pes_total = pes_angle * pes_radi * f_carretera
  
  {
    pes: pes_total,
    desglossat: {
      angle: pes_angle.round(2),
      radi: pes_radi.round(2),
      carretera: tipus_carretera.to_s,
      factor_c: f_carretera
    }
  }
end

puts "📊 ICRv3 - FÓRMULA FINAL (Angle + Radi + Tipus Carretera)"
puts "=" * 70
puts ""
puts "Tipus de carretera:"
puts "  🛤️  Local (L):      Factor ×1.4  - Carreteres locals, pistes (BV, TV, GI)"
puts "  🛣️  Provincial (P): Factor ×1.15 - C-roads, comarcals (C-26, C-16)"
puts "  🛤️  Nacional (N):   Factor ×0.9  - Nacionals principals (N-II, N-340)"
puts ""
puts "-" * 70
puts ""

# Exemples del rànquing català
ejemplos = [
  { nom: "Olesa-Avinyonet (paella)", angle: 170, radi: 30, tipus: :local },
  { nom: "PN.Garraf (paella tancada)", angle: 160, radi: 25, tipus: :local },
  { nom: "Capdevànol-Gombrèn (C-26)", angle: 80, radi: 45, tipus: :provincial },
  { nom: "Gavà-Begues (BV-2001)", angle: 80, radi: 35, tipus: :local },
  { nom: "Corba ràpida N-II", angle: 45, radi: 200, tipus: :nacional },
]

ejemplos.each do |ex|
  resultat = calcular_icrv3(angle: ex[:angle], radi: ex[:radi], tipus_carretera: ex[:tipus])
  puts "🛣️  #{ex[:nom]}"
  puts "   #{ex[:angle]}° | R=#{ex[:radi]}m | #{ex[:tipus]} → Pes: #{resultat[:pes].round(1)}"
  puts ""
end

puts "=" * 70
puts ""
puts "🎯 Càlcul ICRv3 per una ruta:"
puts "   ICRv3 = Σ Pesos / km × Sinuositat² × 0.8"
puts ""
puts "📋 Avantatges d'aquesta versió:"
puts "   ✓ Radi del revolt (més precís que només angle)"
puts "   ✓ Tipus de carretera (N/P/L = amplada + dificultat típica)"
puts "   ✓ Simple d'aplicar (sense pendent ni altres factors)"
puts "   ✓ Reflecteix la realitat del motorista"
puts "=" * 70
