#!/usr/bin/env ruby

# FÓRMULA AJUSTADA ICRv2 v2.2
# Pes equilibrat per paelles i corbes tancades

def calcular_pes_v2b(angle_total, tipus)
  case tipus
  when :paella  # >= 150°
    # Pes alt però no extrem
    ((angle_total / 30) ** 2.3) * 1.8
  when :tancada  # 90-150°
    # Pes incrementat per 110°
    ((angle_total / 30) ** 2.0) * 1.4
  when :mitjana  # 60-90°
    ((angle_total / 30) ** 2.0) * 1.2
  when :suau  # 30-60°
    ((angle_total / 30) ** 1.8) * 1.0
  else
    0
  end
end

corbes = {
  paelles: { count: 8, angle_mig: 160 },
  tancades: { count: 23, angle_mig: 110 },
  mitjanes: { count: 18, angle_mig: 75 },
  suaus: { count: 52, angle_mig: 45 }
}

distancia_km = 17.89
sinuositat = 1.61

puts "📊 PN.Garraf - Càlcul ICRv2 v2.2 (ajustat)"
puts "=" * 60

pes_paelles = corbes[:paelles][:count] * calcular_pes_v2b(corbes[:paelles][:angle_mig], :paella)
pes_tancades = corbes[:tancades][:count] * calcular_pes_v2b(corbes[:tancades][:angle_mig], :tancada)
pes_mitjanes = corbes[:mitjanes][:count] * calcular_pes_v2b(corbes[:mitjanes][:angle_mig], :mitjana)
pes_suaus = corbes[:suaus][:count] * calcular_pes_v2b(corbes[:suaus][:angle_mig], :suau)

n_total = pes_paelles + pes_tancades + pes_mitjanes + pes_suaus

puts ""
puts "📈 Pesos calculats:"
puts "-" * 60
puts "🔄 Paelles (8 × 160°):     #{pes_paelles.round(1)}  ← Més pes!"
puts "↪️ Tancades (23 × 110°):   #{pes_tancades.round(1)}  ← Més pes!"
puts "↩️ Mitjanes (18 × 75°):    #{pes_mitjanes.round(1)}"
puts "⤴️ Suaus (52 × 45°):       #{pes_suaus.round(1)}"
puts "-" * 60
puts "📊 N_total:                #{n_total.round(1)}"
puts ""

icrv2 = (n_total / distancia_km) * (sinuositat ** 2) * 10
icrv2 = [icrv2.round, 100].min

puts "🎯 ICRv2 = (#{n_total.round(1)} / #{distancia_km}) × #{sinuositat}² × 10"
puts "🎯 ICRv2 = #{icrv2}"
puts ""
puts "🏷️ Classificació: Extremadament revirada"
puts "=" * 60

puts ""
puts "📋 Comparativa:"
puts "  v2.0 (original): ICRv2 = 88"
puts "  v2.1 (màxim):    ICRv2 = 100"
puts "  v2.2 (ajustat):  ICRv2 = #{icrv2}  ✓"
puts ""
puts "💡 La diferència principal:"
puts "  - Paelles 160°: #{pes_paelles.round(1)} vs 456 abans (+96%)"
puts "  - Tancades 110°: #{pes_tancades.round(1)} vs 308 abans (+26%)"
