#!/usr/bin/env ruby
require_relative 'lib/ircv2'

file = ARGV[0] || 'track.gpx'
puts "📄 Analitzant: #{file}"
puts "=" * 50

begin
  route = ICRv2::Route.from_gpx(file, sample_distance: 50)
    .analyze!(angle_threshold: 30)
  
  route.summary
  
  puts "\n📋 Top 10 revolts més tancats:"
  route.turns.sort_by { |t| -t.weight }.first(10).each_with_index do |turn, i|
    puts " #{i+1}. #{turn.direction == :left ? '⬅️' : '➡️'} " \
         "#{turn.angle.round(1)}° | R=#{turn.radius.round(0)}m | " \
         "pes=#{turn.weight.round(2)}"
  end
  
  # Exportar
  File.write('resultats_torresfals.json', route.to_json)
  puts "\n💾 Resultats guardats a: resultats_torresfals.json"
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
end
