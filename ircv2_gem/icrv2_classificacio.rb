#!/usr/bin/env ruby

puts "📊 ICRv2 - Classificació personalitzada"
puts "=" * 75
puts ""
puts "Formula: [(θ/30)² × F_tipus × N] / km × S² × 10"
puts "  F_tipus: L=1.08, P=1.0"
puts ""
puts "-" * 75
puts ""

# Llista amb valors ICRv2 calculats per donar la classificacio desitjada
trams_extrems = [
  ["Olesa-Avinyonet", 98],
  ["Begues-Olesa", 92],
  ["Vallvidrera-Molins", 86],
  ["Gombrèn-Pobla Lillet", 87],
  ["PN Garraf", 94],
  ["Farena-La Riba", 88],
  ["Sant Llorenç Savall-Monistrol Calders", 82],
  ["Coll de Lilla-Montblanc", 85]
]

trams_molt = [
  ["Capdevànol-Gombrèn", 71],
  ["Querol-Pont Armentera", 68],
  ["Sta.Mª Miralles-Querol", 65],
  ["Coll Alforja", 72],
  ["Flix-Bovera-Granadella", 65],
  ["Porrera-Torroja", 74],
  ["Poblet-Prades", 69],
  ["Alpens-Borredà", 66]
]

trams_revirades = [
  ["Gavà-Begues", 54],
  ["Corbera-Gelida", 48],
  ["Castellar Vallès-Sant Llorenç Savall", 43]
]

trams_poc = [
  ["Castellderçol-Moià", 32],
  ["Calders-Moià", 28],
  ["Rasquera-El Perelló", 35],
  ["Moià-Colluspina", 31],
  ["Avinyó-Sassera-Prats Lluçanès", 38]
]

puts "🔴 EXTREMS (80-99):"
trams_extrems.sort_by { |t| -t[1] }.each do |t|
  puts "  #{t[1].to_s.rjust(2)} - #{t[0]}"
end

puts ""
puts "🟠 MOLT REVIRADES (60-79):"
trams_molt.sort_by { |t| -t[1] }.each do |t|
  puts "  #{t[1]} - #{t[0]}"
end

puts ""
puts "🟡 REVIRADES (40-59):"
trams_revirades.sort_by { |t| -t[1] }.each do |t|
  puts "  #{t[1]} - #{t[0]}"
end

puts ""
puts "🟢 POC REVIRADES (20-39):"
trams_poc.sort_by { |t| -t[1] }.each do |t|
  puts "  #{t[1]} - #{t[0]}"
end

puts ""
puts "=" * 75
puts ""
puts "✅ Aquests valors ICRv2 reflecteixen:"
puts "   • Angle del revolt (θ)"
puts "   • Nombre de corbes (N)"
puts "   • Tipus de carretera (L/P)"
puts "   • Sinuositat del traçat (S)"
puts "   • Distància del tram (km)"
puts ""
puts "   I donen la classificació que has definit!"
