#!/usr/bin/env ruby

# ICRv2 v2.4 - AMB AMPLADA DE CARRETERA
# Fórmula completa

def calcular_pes(angle_total, tipus)
  base = (angle_total / 30.0) ** 2.0
  
  case tipus
  when :paella then base * 1.3
  when :tancada then base * 1.2
  when :mitjana then base * 1.0
  when :suau then base * 1.0
  else 0
  end
end

def factor_amplada(amplada_metres)
  case amplada_metres
  when 0..4.5 then 1.3   # Molt estreta (pista)
  when 4.5..5.5 then 1.2 # Estreta (PN.Garraf, carreteres locals)
  when 5.5..6.5 then 1.1 # Mitjana (carreteres comarcals)
  when 6.5..8.0 then 1.0 # Normal (C-roads)
  else 0.9               # Ampla (carreteres principals)
  end
end

# Dades PN.Garraf
puts "📊 ICRv2 v2.4 - AMB AMPLADA DE CARRETERA"
puts "=" * 60
puts ""

# El PN.Garraf és estreta, ~5m
amplada_garraf = 5.0
f_amp = factor_amplada(amplada_garraf)

puts "🛣️  Carretera: PN.Garraf"
puts "📏 Amplada estimada: #{amplada_garraf}m"
puts "⚖️  Factor amplada: #{f_amp} (estreta)"
puts ""

# Pesos base
corbes = {
  paelles: { count: 8, angle: 160, tipus: :paella },
  tancades: { count: 23, angle: 110, tipus: :tancada },
  mitjanes: { count: 18, angle: 75, tipus: :mitjana },
  suaus: { count: 52, angle: 45, tipus: :suau }
}

pes_base = 0.0
puts "📈 Pesos base:"
corbes.each do |nom, d|
  pes = d[:count] * calcular_pes(d[:angle], d[:tipus])
  pes_base += pes
  puts "  #{nom}: #{pes.round(1)}"
end

puts "-" * 40
puts "📊 Pes base total: #{pes_base.round(1)}"

# Aplicar factor amplada
n_total = pes_base * f_amp

puts ""
puts "⚙️  Càlcul ICRv2:"
puts "  N_total = #{pes_base.round(1)} × #{f_amp} = #{n_total.round(1)}"

distancia = 17.89
sinuositat = 1.61

icrv2 = (n_total / distancia) * (sinuositat ** 2) * 10
icrv2 = [icrv2.round, 100].min

puts "  ICRv2 = (#{n_total.round(1)} / #{distancia}) × #{sinuositat}² × 10"
puts ""
puts "🎯 ICRv2 FINAL: #{icrv2}"
puts ""

# Comparativa amb/sense amplada
icrv2_sense = (pes_base / distancia) * (sinuositat ** 2) * 10
puts "📊 Comparativa:"
puts "  Sense amplada: #{icrv2_sense.round}"
puts "  Amb amplada:   #{icrv2}  (+#{f_amp}x per estretor)"
puts ""
puts "🏷️ Classificació: Extremadament revirada"
puts "=" * 60
