#!/usr/bin/env ruby
require 'rexml/document'

EARTH_RADIUS = 6_371_000.0

def haversine_distance(lat1, lon1, lat2, lon2)
  d_lat = (lat2 - lat1) * Math::PI / 180.0
  d_lon = (lon2 - lon1) * Math::PI / 180.0
  lat1_rad = lat1 * Math::PI / 180.0
  lat2_rad = lat2 * Math::PI / 180.0
  a = Math.sin(d_lat/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(d_lon/2)**2
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  EARTH_RADIUS * c
end

def angle_between(p1, p2, p3)
  v1_x = p2[:lon] - p1[:lon]
  v1_y = p2[:lat] - p1[:lat]
  v2_x = p3[:lon] - p2[:lon]
  v2_y = p3[:lat] - p2[:lat]
  dot = v1_x * v2_x + v1_y * v2_y
  det = v1_x * v2_y - v1_y * v2_x
  angle = Math.atan2(det.abs, dot)
  angle * 180.0 / Math::PI
end

# Llegir GPX
gpx = REXML::Document.new(File.read('track.gpx'))
all_points = []

gpx.elements.each('//trkpt') do |pt|
  all_points << {
    lat: pt.attributes['lat'].to_f,
    lon: pt.attributes['lon'].to_f
  }
end

# Filtrar segment: Olivella (41.3, 1.81) -> Castelldefels (41.26, 1.97)
# Aproximació per coordenades
segment_points = all_points.select do |p|
  p[:lat] >= 41.24 && p[:lat] <= 41.35 && 
  p[:lon] >= 1.75 && p[:lon] <= 2.05
end

puts "📄 Segment: Olivella -> PN.Garraf -> Castelldefels"
puts "📍 Punts del segment: #{segment_points.size}"
puts "=" * 50

if segment_points.size < 3
  puts "❌ No hi ha prou punts per analitzar"
  exit
end

# Distància
distancia_total = 0.0
segment_points.each_cons(2) { |p1, p2| distancia_total += haversine_distance(p1[:lat], p1[:lon], p2[:lat], p2[:lon]) }
distancia_km = distancia_total / 1000.0

puts "📏 Distància segment: #{distancia_km.round(2)} km"

# Revolts
revolts = []
segment_points.each_cons(3) do |p1, p2, p3|
  angle = angle_between(p1, p2, p3)
  if angle > 30
    revolts << { angle: angle }
  end
end

puts "↩️ Revolts detectats (>30°): #{revolts.size}"
puts "📈 Revolts/km: #{revolts.size / distancia_km.round(2)}"

if revolts.size > 0
  angle_mig = revolts.sum { |r| r[:angle] } / revolts.size
  densitat = revolts.size / distancia_km
  icrv2_est = (densitat * (angle_mig / 30) * 15).round
  icrv2_est = [icrv2_est, 100].min
  
  classificacio = case icrv2_est
    when 0..10 then "Recta/Còmode"
    when 10..30 then "Revirada moderada"
    when 30..50 then "Bastant revirada"
    when 50..70 then "Molt revirada"
    when 70..100 then "Extremadament revirada"
    else "Crítica"
  end
  
  puts "-" * 50
  puts "🎯 ICRv2 estimat: #{icrv2_est}"
  puts "🏷️ Classificació: #{classificacio}"
end

puts "=" * 50
