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

# Llegir GPX - track points (trkpt) no route points (rtept)
gpx = REXML::Document.new(File.read('pn_garraf.gpx'))
points = []

# Intentar llegir track points primer, si no existeixen, llegir route points
gpx.elements.each('//trkpt') do |pt|
  points << {
    lat: pt.attributes['lat'].to_f,
    lon: pt.attributes['lon'].to_f
  }
end

# Si no hi ha track points, llegir route points
if points.empty?
  gpx.elements.each('//rtept') do |pt|
    points << {
      lat: pt.attributes['lat'].to_f,
      lon: pt.attributes['lon'].to_f
    }
  end
end

puts "📄 Track: 20260218_torresfals-v4"
puts "📍 Punts trobats: #{points.size}"
puts "=" * 50

# Distància total
distancia_total = 0.0
points.each_cons(2) { |p1, p2| distancia_total += haversine_distance(p1[:lat], p1[:lon], p2[:lat], p2[:lon]) }
distancia_km = distancia_total / 1000.0

puts "📏 Distància total: #{distancia_km.round(2)} km"

# Detectar revolts (angles > 30°)
revolts = []
points.each_cons(3) do |p1, p2, p3|
  angle = angle_between(p1, p2, p3)
  if angle > 30
    revolts << { angle: angle, lat: p2[:lat], lon: p2[:lon] }
  end
end

puts "↩️ Revolts detectats (>30°): #{revolts.size}"
puts "📈 Revolts/km: #{(revolts.size / distancia_km).round(2)}"

# Estimació ICRv2 (simplificada)
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
