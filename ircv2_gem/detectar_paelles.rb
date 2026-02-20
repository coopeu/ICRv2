#!/usr/bin/env ruby
require 'rexml/document'

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

def turn_direction(p1, p2, p3)
  cross = (p2[:lon] - p1[:lon]) * (p3[:lat] - p2[:lat]) - (p2[:lat] - p1[:lat]) * (p3[:lon] - p2[:lon])
  cross > 0 ? :left : :right
end

gpx = REXML::Document.new(File.read('pn_garraf.gpx'))
points = []
gpx.elements.each('//trkpt') { |pt| points << { lat: pt.attributes['lat'].to_f, lon: pt.attributes['lon'].to_f } }

puts "📄 PN.Garraf - Detecció de corbes"
puts "=" * 60

# Detectar tots els girs amb direcció
girs = []
points.each_cons(3).with_index do |(p1, p2, p3), i|
  angle = angle_between(p1, p2, p3)
  dir = turn_direction(p1, p2, p3)
  
  if angle > 15
    girs << { 
      index: i, 
      angle: angle, 
      dir: dir,
      lat: p2[:lat], 
      lon: p2[:lon]
    }
  end
end

# Agrupar corbes consecutives del mateix sentit
corbes = []
corba_actual = nil

girs.each do |g|
  if corba_actual.nil? || corba_actual[:dir] != g[:dir]
    corbes << corba_actual if corba_actual
    corba_actual = { 
      angles: [g[:angle]], 
      dir: g[:dir], 
      start_idx: g[:index],
      lat: g[:lat],
      lon: g[:lon]
    }
  else
    corba_actual[:angles] << g[:angle]
  end
end
corbes << corba_actual if corba_actual

# Classificar corbes
paelles_180 = []
corbes_tancades = []
corbes_mitjanes = []
corbes_suaus = []

corbes.each do |c|
  angle_total = c[:angles].sum
  count = c[:angles].size
  
  if angle_total >= 150 && angle_total < 210
    paelles_180 << c.merge(total: angle_total)
  elsif angle_total >= 90
    corbes_tancades << c.merge(total: angle_total)
  elsif angle_total >= 60
    corbes_mitjanes << c.merge(total: angle_total)
  else
    corbes_suaus << c.merge(total: angle_total)
  end
end

puts "📊 RESULTATS:"
puts "-" * 60
puts "🔄 Paelles (~180°):          #{paelles_180.size}"
puts "↪️ Corbes tancades (>90°):   #{corbes_tancades.size}"
puts "↩️ Corbes mitjanes (60-90°): #{corbes_mitjanes.size}"
puts "⤴️ Corbes suaus (<60°):     #{corbes_suaus.size}"
puts ""

if paelles_180.size > 0
  puts "📍 Detall de paelles (ferradures ~180°):"
  paelles_180.each_with_index do |p, i|
    puts "  #{i+1}. #{p[:total].round(1)}° (#{p[:angles].size} segments) #{p[:dir] == :left ? '⬅️' : '➡️'}"
  end
  puts ""
end

if corbes_tancades.size > 0
  puts "📍 Corbes tancades (>90°):"
  corbes_tancades.first(5).each_with_index do |c, i|
    puts "  #{i+1}. #{c[:total].round(1)}° (#{c[:angles].size} segments)"
  end
  puts "  ... i #{corbes_tancades.size - 5} més" if corbes_tancades.size > 5
end

puts "-" * 60
puts "✅ Total corbes significatives: #{corbes.size}"
puts "✅ Coincideix amb les teves 7 paelles?"
