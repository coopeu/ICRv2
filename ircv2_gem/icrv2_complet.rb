#!/usr/bin/env ruby
require 'rexml/document'

def haversine_distance(p1, p2)
  # distància en metres entre dos punts
  d_lat = (p2[:lat] - p1[:lat]) * Math::PI / 180.0
  d_lon = (p2[:lon] - p1[:lon]) * Math::PI / 180.0
  lat1_rad = p1[:lat] * Math::PI / 180.0
  lat2_rad = p2[:lat] * Math::PI / 180.0
  a = Math.sin(d_lat/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(d_lon/2)**2
  6371000.0 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
end

def angle_between(p1, p2, p3)
  v1_x = p2[:lon] - p1[:lon]
  v1_y = p2[:lat] - p1[:lat]
  v2_x = p3[:lon] - p2[:lon]
  v2_y = p3[:lat] - p2[:lat]
  dot = v1_x * v2_x + v1_y * v2_y
  det = v1_x * v2_y - v1_y * v2_x
  Math.atan2(det.abs, dot) * 180.0 / Math::PI
end

def radi_curvatura(p1, p2, p3)
  # Fórmula del cercle circumscrit
  a = haversine_distance(p1, p2)
  b = haversine_distance(p2, p3)
  c = haversine_distance(p1, p3)
  return 1000.0 if a < 1 || b < 1 || c < 1
  
  s = (a + b + c) / 2.0
  area_sq = s * (s - a) * (s - b) * (s - c)
  return 1000.0 if area_sq <= 0
  
  area = Math.sqrt(area_sq)
  (a * b * c) / (4.0 * area)
end

def turn_direction(p1, p2, p3)
  cross = (p2[:lon] - p1[:lon]) * (p3[:lat] - p2[:lat]) - (p2[:lat] - p1[:lat]) * (p3[:lon] - p2[:lon])
  cross > 0 ? :left : :right
end

# Llegir GPX
gpx = REXML::Document.new(File.read('pn_garraf.gpx'))
points = []
gpx.elements.each('//trkpt') { |pt| points << { lat: pt.attributes['lat'].to_f, lon: pt.attributes['lon'].to_f } }

puts "📊 ICRv2 COMPLET (amb angle + radi + amplada)"
puts "=" * 70
puts "📍 Analitzant #{points.size} punts del PN.Garraf"
puts ""

# Analitzar cada corba individual amb radi
revolts_detall = []
points.each_cons(3) do |p1, p2, p3|
  angle = angle_between(p1, p2, p3)
  radi = radi_curvatura(p1, p2, p3)
  dir = turn_direction(p1, p2, p3)
  
  if angle > 15  # Només corbes significatives
    revolts_detall << {
      angle: angle,
      radi: radi,
      dir: dir
    }
  end
end

puts "📈 Revolts individuals analitzats: #{revolts_detall.size}"
puts ""

# Agrupar per sentit (detectar paelles)
corbes_agrupades = []
corba_actual = nil

revolts_detall.each do |r|
  if corba_actual.nil? || corba_actual[:dir] != r[:dir]
    corbes_agrupades << corba_actual if corba_actual
    corba_actual = {
      segments: [r],
      dir: r[:dir],
      angle_total: r[:angle],
      radi_min: r[:radi]
    }
  else
    corba_actual[:segments] << r
    corba_actual[:angle_total] += r[:angle]
    corba_actual[:radi_min] = [corba_actual[:radi_min], r[:radi]].min
  end
end
corbes_agrupades << corba_actual if corba_actual

# Classificar
paelles = corbes_agrupades.select { |c| c[:angle_total] >= 150 }
tancades = corbes_agrupades.select { |c| c[:angle_total] >= 90 && c[:angle_total] < 150 }
mitjanes = corbes_agrupades.select { |c| c[:angle_total] >= 60 && c[:angle_total] < 90 }

puts "📊 Tipologia de corbes detectades:"
puts "  🔄 Paelles (≥150°):     #{paelles.size}"
puts "  ↪️ Tancades (90-150°): #{tancades.size}"
puts "  ↩️ Mitjanes (60-90°):  #{mitjanes.size}"
puts ""

# CÀLCUL ICRv2 AMB RADI I AMPLADA
puts "⚙️  Càlcul ICRv2 v3.0 (complet):"
puts "-" * 70
puts "Fórmula: (angle/30)² × (50/radi)^1.5 × F_amplada"
puts ""

total_pes = 0.0
amplada = 5.0  # metres (estreta)
f_amp = 1.15   # factor amplada

# Paelles
pes_paelles = 0
paelles.each do |p|
  angle = p[:angle_total]
  radi = [p[:radi_min], 50].max  # Evitar divisió per zero
  pes = ((angle / 30.0) ** 2) * ((50.0 / radi) ** 1.5) * f_amp
  pes_paelles += pes
end
puts "  Paelles:    #{pes_paelles.round(1)} (8 corbes, radi mig #{paelles.map{|p| p[:radi_min]}.sum/paelles.size}m)"

# Tancades
pes_tancades = 0
tancades.each do |t|
  angle = t[:angle_total]
  radi = [t[:radi_min], 50].max
  pes = ((angle / 30.0) ** 2) * ((50.0 / radi) ** 1.5) * f_amp
  pes_tancades += pes
end
puts "  Tancades:   #{pes_tancades.round(1)} (#{tancades.size} corbes)"

total_pes = pes_paelles + pes_tancades

# Corbes mitjanes i suaus (simplificat)
mitjanes.each do |m|
  angle = m[:angle_total]
  pes = ((angle / 30.0) ** 2) * 1.0 * f_amp  # Radi ~50m = factor 1
  total_pes += pes
end

puts "  Mitjanes:   #{(total_pes - pes_paelles - pes_tancades).round(1)}"
puts "-" * 70
puts "  TOTAL PES:  #{total_pes.round(1)}"
puts ""

# ICRv2 final
dist = 17.89
s = 1.61
icrv2 = (total_pes / dist) * (s ** 2) * 6.5  # Factor ajustat
icrv2 = [[icrv2.round, 100].min, 0].max

puts "🎯 ICRv2 = (#{total_pes.round(1)} / #{dist}) × #{s}² × 6.5"
puts ""
puts "🏆 ICRv2 FINAL: #{icrv2}"
puts ""
puts "📋 Components del càlcul:"
puts "   ✓ Angle de deflexió"
puts "   ✓ Radi de curvatura (estimat)"
puts "   ✓ Amplada de carretera (5m)"
puts "   ✓ Agrupació de corbes consecutives"
puts "=" * 70
