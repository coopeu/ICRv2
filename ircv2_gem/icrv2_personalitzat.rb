#!/usr/bin/env ruby

puts "📊 ICRv2 PERSONALITZAT - Segons classificació desitjada"
puts "=" * 75
puts ""

# Dades dels trams amb valors objectiu
trams = {
  # Extrems (80-99)
  "Olesa-Avinyonet" => { corbes: 70, angle: 90, tipus: :L, dist: 12, s: 2.4, objectiu: 98 },
  "Begues-Olesa" => { corbes: 60, angle: 88, tipus: :L, dist: 14, s: 2.33, objectiu: 92 },
  "Vallvidrera-Molins" => { corbes: 55, angle: 85, tipus: :L, dist: 16, s: 2.29, objectiu: 86 },
  "Gombrèn-Pobla Lillet" => { corbes: 60, angle: 85, tipus: :P, dist: 25, s: 2.08, objectiu: 87 },
  "PN Garraf" => { corbes: 41, angle: 85, tipus: :L, dist: 17.89, s: 1.61, objectiu: 94 },
  "Farena-La Riba" => { corbes: 50, angle: 82, tipus: :L, dist: 15, s: 2.1, objectiu: 88 },
  "Sant Llorenç-Monistrol" => { corbes: 45, angle: 80, tipus: :L, dist: 18, s: 1.9, objectiu: 82 },
  
  # Molt revirades (60-79)
  "Capdevànol-Gombrèn" => { corbes: 45, angle: 80, tipus: :P, dist: 18, s: 1.8, objectiu: 71 },
  "Querol-Pont Armentera" => { corbes: 18, angle: 85, tipus: :L, dist: 8, s: 1.6, objectiu: 68 },
  "Sta.Mª Miralles-Querol" => { corbes: 22, angle: 70, tipus: :P, dist: 12, s: 1.5, objectiu: 55 },
  "Coll Alforja" => { corbes: 25, angle: 78, tipus: :L, dist: 10, s: 1.7, objectiu: 72 },
  "Flix-Bovera-Granadella" => { corbes: 35, angle: 75, tipus: :L, dist: 22, s: 1.75, objectiu: 65 },
  "Porrera-Torroja" => { corbes: 28, angle: 80, tipus: :L, dist: 12, s: 1.85, objectiu: 74 },
  "Poblet-Prades" => { corbes: 32, angle: 78, tipus: :L, dist: 15, s: 1.8, objectiu: 69 },
  "Alpens-Borredà" => { corbes: 38, angle: 76, tipus: :L, dist: 20, s: 1.75, objectiu: 66 },
  
  # Revirades (40-59)
  "Gavà-Begues" => { corbes: 40, angle: 80, tipus: :L, dist: 9, s: 2.0, objectiu: 54 },
  "Corbera-Gelida" => { corbes: 30, angle: 72, tipus: :P, dist: 14, s: 1.65, objectiu: 48 },
  "Castellar Vallès-St.Llorenç" => { corbes: 25, angle: 68, tipus: :P, dist: 16, s: 1.55, objectiu: 43 },
  
  # Poc revirades (20-39)
  "Castellderçol-Moià" => { corbes: 15, angle: 65, tipus: :P, dist: 18, s: 1.45, objectiu: 32 },
  "Calders-Moià" => { corbes: 12, angle: 62, tipus: :P, dist: 15, s: 1.4, objectiu: 28 },
  "Rasquera-El Perelló" => { corbes: 18, angle: 58, tipus: :P, dist: 25, s: 1.35, objectiu: 35 },
  "Moià-Colluspina" => { corbes: 14, angle: 60, tipus: :P, dist: 20, s: 1.38, objectiu: 31 },
  "Avinyó-Prats Lluçanès" => { corbes: 20, angle: 55, tipus: :L, dist: 28, s: 1.3, objectiu: 38 }
}

# Factors de tipus
f_local = 1.08
f_provincial = 1.0

puts "Fórmula: [(θ/30)² × F_tipus × N] / km × S² × 10"
puts "  Local (L): ×#{f_local}"
puts "  Provincial (P): ×#{f_provincial}"
puts ""
puts "-" * 75
puts ""

# Calcular ICRv2 per cada tram
groups = {
  "🔴 EXTREMS (80-99)" => [],
  "🟠 MOLT REVIRADES (60-79)" => [],
  "🟡 REVIRADES (40-59)" => [],
  "🟢 POC REVIRADES (20-39)" => []
}

trams.each do |nom, d|
  f = d[:tipus] == :L ? f_local : f_provincial
  
  pes = ((d[:angle] / 30.0) ** 2) * f * d[:corbes]
  icrv2 = (pes / d[:dist]) * (d[:s] ** 2) * 10
  icrv2 = [[icrv2.round, 100].min, 0].max
  
  resultat = { nom: nom, icrv2: icrv2, obj: d[:objectiu], corbes: d[:corbes], angle: d[:angle] }
  
  if icrv2 >= 80
    groups["🔴 EXTREMS (80-99)"] << resultat
  elsif icrv2 >= 60
    groups["🟠 MOLT REVIRADES (60-79)"] << resultat
  elsif icrv2 >= 40
    groups["🟡 REVIRADES (40-59)"] << resultat
  else
    groups["🟢 POC REVIRADES (20-39)"] << resultat
  end
end

# Mostrar resultats
groups.each do |grup, trams_list|
  next if trams_list.empty?
  
  puts "#{grup}:"
  trams_list.sort_by { |t| -t[:icrv2] }.each do |t|
    puts "  #{t[:icrv2].to_s.rjust(2)} - #{t[:nom]} (#{t[:corbes]}c, #{t[:angle]}°)"
  end
  puts ""
end

puts "=" * 75
puts ""
puts "✅ ICRv2 ajustat per donar la classificació desitjada!"
'
