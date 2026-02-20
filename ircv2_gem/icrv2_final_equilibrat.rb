#!/usr/bin/env ruby

# ICRv2 v2.5 - VERSIÓ EQUILIBRADA AMB AMPLADA
# Objectiu: ~94 per PN.Garraf (no saturar a 100)

def calcular_pes(angle_total, tipus)
  base = (angle_total / 30.0) ** 2.0
  
  case tipus
  when :paella then base * 1.15  # +15% paelles
  when :tancada then base * 1.10  # +10% tancades
  when :mitjana then base * 1.0
  when :suau then base * 1.0
  else 0
  end
end

def factor_amplada(metres)
  case metres
  when 0..4.5 then 1.2
  when 4.5..5.5 then 1.15  # PN.Garraf ~5m
  when 5.5..6.5 then 1.1
  when 6.5..8.0 then 1.0
  else 0.9
  end
end

puts "📊 ICRv2 v2.5 - EQUILIBRADA AMB AMPLADA"
puts "=" * 60

# PN.Garraf
corbes = { paelles: [8,160], tancades: [23,110], mitjanes: [18,75], suaus: [52,45] }
tipus = { paelles: :paella, tancades: :tancada, mitjanes: :mitjana, suaus: :suau }
amplada = 5.0
f_amp = factor_amplada(amplada)

pes_base = 0.0
corbes.each { |nom, d| pes_base += d[0] * calcular_pes(d[1], tipus[nom]) }

n_total = pes_base * f_amp
dist = 17.89
s = 1.61

icrv2 = (n_total / dist) * (s ** 2) * 10
icrv2 = [[icrv2.round, 100].min, 0].max

puts ""
puts "🛣️  PN.Garraf (#{amplada}m amplada)"
puts "⚖️  Factor amplada: #{f_amp}"
puts "📊 Pes base: #{pes_base.round(1)} × #{f_amp} = #{n_total.round(1)}"
puts ""
puts "🎯 ICRv2 = #{icrv2}"
puts ""

# Altres exemples per calibrar
puts "📋 Calibració amb altres carreteres:"
puts "-" * 60

# Exemple: Carretera còmoda (poc revolts, amplada normal)
pes_comoda = 20 * ((30.0/30)**2) * 1.0
icrv2_comoda = (pes_comoda / 10.0) * (1.2 ** 2) * 10 * 1.0
puts "  Carretera còmoda (ample): #{icrv2_comoda.round}"

# Exemple: Olesa-Avinyonet (molts revolts, estreta)
pes_olesa = 70 * ((90.0/30)**2) * 1.15 * 1.15  # paelles + estreta
icrv2_olesa = (pes_olesa / 12.0) * (2.4 ** 2) * 10
puts "  Olesa-Avinyonet (estreta): #{[icrv2_olesa.round, 100].min}"

puts ""
puts "✅ Escala ajustada:"
puts "   • 0-30: Còmode"
puts "   • 30-50: Moderat"  
puts "   • 50-70: Revirada"
puts "   • 70-90: Molt revirada"
puts "   • 90-100: Extremadament revirada"
puts "=" * 60
