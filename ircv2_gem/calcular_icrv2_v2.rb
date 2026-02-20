#!/usr/bin/env ruby

# NOVA FÓRMULA ICRv2 amb més pes a paelles
# Versió 2.1 - Correcció per corbes tancades

def calcular_pes_v2(angle_total, tipus)
  case tipus
  when :paella  # >= 150°
    # Exponencial més agressiva per paelles
    ((angle_total / 30) ** 2.5) * 2.0
  when :tancada  # 90-150°
    # Pes elevat per corbes tancades
    ((angle_total / 30) ** 2.2) * 1.5
  when :mitjana  # 60-90°
    # Pes estàndard
    ((angle_total / 30) ** 2.0) * 1.2
  when :suau  # 30-60°
    # Pes reduït
    ((angle_total / 30) ** 1.8) * 1.0
  else
    0
  end
end

# Dades del PN.Garraf
corbes = {
  paelles: { count: 8, angle_mig: 160 },      # 8 paelles ~180°
  tancades: { count: 23, angle_mig: 110 },    # 23 corbes >90°
  mitjanes: { count: 18, angle_mig: 75 },     # 18 corbes 60-90°
  suaus: { count: 52, angle_mig: 45 }         # 52 corbes 30-60°
}

distancia_km = 17.89
sinuositat = 1.61

puts "📊 PN.Garraf - Càlcul ICRv2 v2.1 (amb més pes a paelles)"
puts "=" * 60

# Càlcul de pesos
pes_paelles = corbes[:paelles][:count] * calcular_pes_v2(corbes[:paelles][:angle_mig], :paella)
pes_tancades = corbes[:tancades][:count] * calcular_pes_v2(corbes[:tancades][:angle_mig], :tancada)
pes_mitjanes = corbes[:mitjanes][:count] * calcular_pes_v2(corbes[:mitjanes][:angle_mig], :mitjana)
pes_suaus = corbes[:suaus][:count] * calcular_pes_v2(corbes[:suaus][:angle_mig], :suau)

n_total = pes_paelles + pes_tancades + pes_mitjanes + pes_suaus

puts ""
puts "📈 Desglossament de pesos:"
puts "-" * 60
puts "🔄 Paelles (8 × 160°):     #{pes_paelles.round(1)}"
puts "↪️ Tancades (23 × 110°):   #{pes_tancades.round(1)}"
puts "↩️ Mitjanes (18 × 75°):    #{pes_mitjanes.round(1)}"
puts "⤴️ Suaus (52 × 45°):       #{pes_suaus.round(1)}"
puts "-" * 60
puts "📊 N_total:                #{n_total.round(1)}"
puts ""

# ICRv2 amb factor 10 (escala 0-100)
icrv2 = (n_total / distancia_km) * (sinuositat ** 2) * 10
icrv2 = [icrv2.round, 100].min

puts "🎯 ICRv2 = (#{n_total.round(1)} / #{distancia_km}) × #{sinuositat}² × 10"
puts "🎯 ICRv2 = #{icrv2}"
puts ""

classificacio = case icrv2
  when 0..10 then "Recta/Còmode"
  when 10..30 then "Revirada moderada"
  when 30..50 then "Bastant revirada"
  when 50..70 then "Molt revirada"
  when 70..100 then "Extremadament revirada"
  else "Crítica"
end

puts "🏷️ Classificació: #{classificacio}"
puts "=" * 60

puts ""
puts "📋 Comparativa versions:"
puts "  v2.0 (abans):  ICRv2 = 88"
puts "  v2.1 (nova):   ICRv2 = #{icrv2}"
