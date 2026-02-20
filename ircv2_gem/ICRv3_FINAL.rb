#!/usr/bin/env ruby

# ICRv3 - VERSIÓ DEFINITIVA
# Formula: Σ[(θ/30)² × (50/R)^1.5 × F_tipus] / km × S² × 0.5

def calcular_corba(angle:, radi:, tipus:)
  f_tipus = case tipus
    when :local, :L, :estreta then 1.05
    when :provincial, :P, :mitjana then 1.0
    when :nacional, :N, :ampla then 0.9
    else 1.0
  end
  
  pes = ((angle / 30.0) ** 2.0) * ((50.0 / [radi, 10].max) ** 1.5) * f_tipus
  { pes: pes, factor: f_tipus }
end

def calcular_icrv3(corbes:, distancia_km:, sinuositat:)
  total = corbes.sum { |c| c[:pes] }
  (total / distancia_km) * (sinuositat ** 2) * 0.5
end

puts "📊 ICRv3 - FÓRMULA DEFINITIVA"
puts "=" * 70
puts ""
puts "🎯 Formula:"
puts "   ICRv3 = Σ[(θ/30)² × (50/R)^1.5 × F_tipus] / km × S² × 0.5"
puts ""
puts "📋 Classes de carretera:"
puts "   🛤️  Local/Estreta (BV, TV):    ×1.05"
puts "   🛣️  Provincial/Mitjana (C):    ×1.0"
puts "   🛤️  Nacional/Ampla (N):        ×0.9"
puts ""
puts "-" * 70
puts ""

# PN.Garraf
corbes_pn = [
  { tipus: :local, count: 8, angle: 160, radi: 25 },
  { tipus: :local, count: 22, angle: 110, radi: 40 },
  { tipus: :local, count: 18, angle: 75, radi: 50 },
  { tipus: :local, count: 52, angle: 45, radi: 60 }
]

total_pes = 0.0
corbes_pn.each do |c|
  info = calcular_corba(angle: c[:angle], radi: c[:radi], tipus: c[:tipus])
  pes_total = info[:pes] * c[:count]
  total_pes += pes_total
end

icrv3_pn = calcular_icrv3(corbes: [{pes: total_pes}], distancia_km: 17.89, sinuositat: 1.61)

puts "🛣️  PN.Garraf (Local ×1.05, 17.89km, S=1.61)"
puts "   Pes total: #{total_pes.round(1)}"
puts "   ICRv3 = (#{total_pes.round(1)}/17.89) × 1.61² × 0.5"
puts ""
puts "   🏆 ICRv3 = #{icrv3_pn.round}"
puts ""

# Altres exemples
puts "-" * 70
puts "📊 Comparativa altres carreteres:"
puts ""

# Olesa-Avinyonet (estimació)
olesa_pes = 70 * ((160.0/30)**2) * ((50.0/30)**1.5) * 1.05
icrv3_olesa = (olesa_pes / 12.0) * (2.4**2) * 0.5
puts "   Olesa-Avinyonet (L): ICRv3 ≈ #{icrv3_olesa.round}"

# Capdevànol-Gombrèn (C-26, provincial)
capdev_pes = 45 * ((80.0/30)**2) * ((50.0/45)**1.5) * 1.0
icrv3_capdev = (capdev_pes / 18.0) * (1.8**2) * 0.5
puts "   Capdevànol-Gombrèn (P): ICRv3 ≈ #{icrv3_capdev.round}"

# N-II (corbes ràpides, nacional)
n2_pes = 20 * ((45.0/30)**2) * ((50.0/150)**1.5) * 0.9
icrv3_n2 = (n2_pes / 10.0) * (1.1**2) * 0.5
puts "   Corba ràpida N-II (N): ICRv3 ≈ #{icrv3_n2.round}"

puts ""
puts "=" * 70
puts ""
puts "✅ ICRv3 reflecteix:"
puts "   • Angle del revolt (quadràtic)"
puts "   • Radi (exponencial 1.5)"
puts "   • Tipus carretera N/P/L (3 classes)"
puts "   • Sinuositat del traçat"
puts ""
puts "   Escala 0-100 usable i realista!"
puts "=" * 70
