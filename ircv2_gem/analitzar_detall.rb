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

gpx = REXML::Document.new(File.read('pn_garraf.gpx'))
points = []
gpx.elements.each('//trkpt') { |pt| points << { lat: pt.attributes['lat'].to_f, lon: pt.attributes['lon'].to_f } }

puts "📄 Track: PN.Garraf (20260218)"
puts "=" * 50

# Distància
dist_total = 0.0
points.each_cons(2) { |p1, p2| dist_total += haversine_distance(p1[:lat], p1[:lon], p2[:lat], p2[:lon]) }
dist_km = dist_total / 1000.0

# Tots els revolts (sense llindar)
tots_revolts = []
points.each_cons(3) do |p1, p2, p3|
  angle = angle_between(p1, p2, p3)
  tots_revolts << angle if angle > 0
end

# Per categories
suau = tots_revolts.count { |a| a >= 15 && a < 30 }
moderat = tots_revolts.count { |a| a >= 30 && a < 60 }
pronunciat = tots_revolts.count { |a| a >= 60 && a < 90 }
tancat = tots_revolts.count { |a| a >= 90 }

# Sinuositat (L_real / L_recta)
first = points.first
last = points.last
straight = haversine_distance(first[:lat], first[:lon], last[:lat], last[:lon])
sinuositat = dist_total / straight

puts "📏 Distància total: #{dist_km.round(2)} km"
puts "📍 Punts GPS: #{points.size}"
puts "〰️ Sinuositat: #{sinuositat.round(2)}"
puts ""
puts "📊 DISTRIBUCIÓ DE REVOLTS:"
puts "-" * 50
puts "Total canvis de direcció: #{tots_revolts.size}"
puts ""
puts "Per dificultat:"
puts "  • Suau (15-30°):    #{suau}"
puts "  • Moderat (30-60°): #{moderat}"
puts "  • Pronunciat (60-90°): #{pronunciat}"
puts "  • Tancat (>90°):    #{tancat}"
puts ""
puts "TOTAL REVOLTS SIGNIFICATIUS (>30°): #{moderat + pronunciat + tancat}"
puts "Revolts/km: #{((moderat + pronunciat + tancat) / dist_km).round(2)}"
puts "=" * 50
