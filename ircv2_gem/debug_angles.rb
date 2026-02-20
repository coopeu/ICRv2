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

gpx = REXML::Document.new(File.read('pn_garraf.gpx'))
points = []
gpx.elements.each('//trkpt') { |pt| points << { lat: pt.attributes['lat'].to_f, lon: pt.attributes['lon'].to_f } }

# Trobar tots els angles grans
angles_grans = []
points.each_cons(3).with_index do |(p1, p2, p3), i|
  angle = angle_between(p1, p2, p3)
  if angle > 60
    angles_grans << { 
      index: i, 
      angle: angle.round(1), 
      lat: p2[:lat].round(5), 
      lon: p2[:lon].round(5) 
    }
  end
end

puts "Angles > 60° trobats: #{angles_grans.size}"
puts "-" * 50

angles_grans.each do |a|
  icon = case a[:angle]
    when 60..90 then "↩️"
    when 90..180 then "↪️"
    when 180..270 then "🔃"
    else "🔄"
  end
  puts "#{icon} #{a[:angle].to_s.rjust(6)}° @ [#{a[:lat]}, #{a[:lon]}]"
end

# Resum per rangs
puts "-" * 50
puts "Resum:"
puts "  60-90°:   #{angles_grans.count { |a| a[:angle] >= 60 && a[:angle] < 90 }}"
puts "  90-180°:  #{angles_grans.count { |a| a[:angle] >= 90 && a[:angle] < 180 }}"
puts "  180-270°: #{angles_grans.count { |a| a[:angle] >= 180 && a[:angle] < 270 }}"
puts "  >270°:    #{angles_grans.count { |a| a[:angle] >= 270 }}"
