# Llibreria ICRv2 - Codi Ruby Complet
# Versió 1.0.0
# 
# Ús:
#   route = ICRv2::Route.from_gpx('ruta.gpx').analyze!
#   puts "ICRv2: #{route.irv2_score}"

require 'nokogiri'
require 'json'

module ICRv2
  VERSION = '1.0.0'
  
  class Error < StandardError; end
  
  # Point struct per coordenades
  Point = Struct.new(:lat, :lon, :ele, :time, keyword_init: true)
  
  # Classe Turn (revolt)
  class Turn
    attr_reader :angle, :radius, :direction, :point_count, :distance_from_previous
    
    def initialize(angle:, radius:, direction:, point_count: 1, distance_from_previous: 0)
      @angle = angle
      @radius = [radius, 1000.0].min  # Limitar radi màxim
      @radius = [@radius, 10.0].max   # Limitar radi mínim
      @direction = direction
      @point_count = point_count
      @distance_from_previous = distance_from_previous
    end
    
    # Factor de ritme segons distància a l'anterior revolt
    def rhythm_factor
      return 1.5 if @distance_from_previous < 100
      return 1.2 if @distance_from_previous < 200
      1.0
    end
    
    # Pes d'aquest revolt segons la fórmula ICRv2
    def weight
      return 0 if @angle < 30
      
      angle_factor = (@angle / 30.0) ** 2
      radius_factor = (50.0 / @radius) ** 1.5
      
      angle_factor * radius_factor * rhythm_factor
    end
    
    def to_h
      {
        angle: @angle.round(2),
        radius: @radius.round(2),
        direction: @direction,
        weight: weight.round(4)
      }
    end
  end
  
  # Mòdul de geometria
  module Geometry
    EARTH_RADIUS = 6_371_000.0  # metres
    
    # Distància Haversine entre dos punts
    def self.haversine_distance(p1, p2)
      d_lat = to_radians(p2.lat - p1.lat)
      d_lon = to_radians(p2.lon - p1.lon)
      lat1 = to_radians(p1.lat)
      lat2 = to_radians(p2.lat)
      
      a = Math.sin(d_lat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(d_lon/2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      
      EARTH_RADIUS * c
    end
    
    # Angle de deflexió entre tres punts (en graus)
    def self.angle_between(p1, p2, p3)
      v1_x = p2.lon - p1.lon
      v1_y = p2.lat - p1.lat
      v2_x = p3.lon - p2.lon
      v2_y = p3.lat - p2.lat
      
      dot = v1_x * v2_x + v1_y * v2_y
      det = v1_x * v2_y - v1_y * v2_x
      
      angle = Math.atan2(det.abs, dot)
      to_degrees(angle)
    end
    
    # Radi de curvatura aproximat (en metres)
    def self.curvature_radius(p1, p2, p3)
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
    
    # Determinar sentit del gir (esquerra/dreta)
    def self.turn_direction(p1, p2, p3)
      cross = (p2.lon - p1.lon) * (p3.lat - p2.lat) - (p2.lat - p1.lat) * (p3.lon - p2.lon)
      cross > 0 ? :left : :right
    end
    
    private
    
    def self.to_radians(degrees)
      degrees * Math::PI / 180.0
    end
    
    def self.to_degrees(radians)
      radians * 180.0 / Math::PI
    end
  end
  
  # Parser de GPX
  class GpxParser
    def initialize(file_path)
      @file_path = file_path
    end
    
    def parse
      doc = Nokogiri::XML(File.read(@file_path))
      
      # Buscar trkpt (track points) amb namespace o sense
      points = doc.xpath('//xmlns:trkpt', xmlns: 'http://www.topografix.com/GPX/1/1')
      points = doc.xpath('//trkpt') if points.empty?
      
      points.map do |node|
        Point.new(
          lat: node['lat'].to_f,
          lon: node['lon'].to_f,
          ele: node.at_xpath('xmlns:ele')&.text&.to_f || node.at_xpath('ele')&.text&.to_f,
          time: node.at_xpath('xmlns:time')&.text || node.at_xpath('time')&.text
        )
      end
    end
  end
  
  # Re-sampleig de punts
  class Resampler
    def initialize(points)
      @points = points
    end
    
    # Re-samplejar punts cada 'distance' metres
    def resample(distance = 100.0)
      return @points if @points.size < 2
      
      result = [@points.first]
      accumulated = 0.0
      
      @points.each_cons(2) do |p1, p2|
        segment_dist = Geometry.haversine_distance(p1, p2)
        
        while accumulated + segment_dist >= distance
          ratio = (distance - accumulated) / segment_dist
          
          new_point = Point.new(
            lat: p1.lat + (p2.lat - p1.lat) * ratio,
            lon: p1.lon + (p2.lon - p1.lon) * ratio,
            ele: p1.ele && p2.ele ? p1.ele + (p2.ele - p1.ele) * ratio : nil
          )
          
          result << new_point
          accumulated = 0.0
          p1 = new_point
          segment_dist = Geometry.haversine_distance(p1, p2)
        end
        
        accumulated += segment_dist
      end
      
      result << @points.last unless result.last == @points.last
      result
    end
  end
  
  # Detector de revolts
  class TurnDetector
    def initialize(points)
      @points = points
    end
    
    def detect(threshold: 30.0)
      return [] if @points.size < 3
      
      turns = []
      current_turn = nil
      last_turn_end_idx = 0
      
      @points.each_cons(3).with_index do |(p1, p2, p3), idx|
        angle = Geometry.angle_between(p1, p2, p3)
        next if angle < threshold
        
        direction = Geometry.turn_direction(p1, p2, p3)
        radius = Geometry.curvature_radius(p1, p2, p3)
        distance_from_prev = calculate_distance(last_turn_end_idx, idx)
        
        if current_turn && current_turn.direction == direction
          # Continuar revolt actual
          current_turn = Turn.new(
            angle: current_turn.angle + angle,
            radius: [current_turn.radius, radius].min,
            direction: direction,
            point_count: current_turn.point_count + 1,
            distance_from_previous: current_turn.distance_from_previous
          )
        else
          # Guardar revolt anterior si existeix
          turns << current_turn if current_turn
          last_turn_end_idx = idx if current_turn
          
          # Nou revolt
          current_turn = Turn.new(
            angle: angle,
            radius: radius,
            direction: direction,
            point_count: 1,
            distance_from_previous: distance_from_prev
          )
        end
      end
      
      turns << current_turn if current_turn
      turns
    end
    
    private
    
    def calculate_distance(from_idx, to_idx)
      return 0 if from_idx >= to_idx
      
      @points[from_idx..to_idx].each_cons(2).sum do |p1, p2|
        Geometry.haversine_distance(p1, p2)
      end
    end
  end
  
  # Calculador d'ICRv2
  class Irv2Calculator
    def initialize(route)
      @route = route
    end
    
    # Versió 0-100 (divideix per 10 respecte la versió 0-1000)
    def calculate
      return 0.0 if @route.turns.empty?
      
      n_total = @route.turns.sum(&:weight)
      l = @route.distance_km
      s = calculate_sinuosity
      
      return 0.0 if l <= 0
      
      # Factor 10 per escala 0-100 (en lloc de 100 per escala 0-1000)
      (n_total / l) * (s ** 2) * 10
    end
    
    private
    
    def calculate_sinuosity
      real_distance = @route.distance_km * 1000.0  # metres
      first = @route.points.first
      last = @route.points.last
      straight_distance = Geometry.haversine_distance(first, last)
      
      return 1.0 if straight_distance < 1.0
      
      sinuosity = real_distance / straight_distance
      [sinuosity, 1.0].max
    end
  end
  
  # Classe principal Route
  class Route
    attr_reader :points, :turns, :irv2_score, :sample_distance
    
    def initialize(points = [], sample_distance: 100)
      @points = points
      @turns = []
      @icrv2_score = 0.0
      @sample_distance = sample_distance
    end
    
    # Factory method: carregar des de GPX
    def self.from_gpx(file_path, sample_distance: 100)
      parser = GpxParser.new(file_path)
      raw_points = parser.parse
      
      raise Error, "No s'han trobat punts al GPX" if raw_points.empty?
      
      resampler = Resampler.new(raw_points)
      points = resampler.resample(sample_distance)
      
      new(points, sample_distance: sample_distance)
    end
    
    # Analitzar la ruta i calcular ICRv2
    def analyze!(angle_threshold: 30.0)
      detector = TurnDetector.new(@points)
      @turns = detector.detect(threshold: angle_threshold)
      
      calculator = Irv2Calculator.new(self)
      @icrv2_score = calculator.calculate
      
      self
    end
    
    # Distància total en km
    def distance_km
      @points.each_cons(2).sum do |p1, p2|
        Geometry.haversine_distance(p1, p2)
      end / 1000.0
    end
    
    # Sinuositat (L_real / L_recta)
    def sinuosity
      real = distance_km * 1000.0
      first = @points.first
      last = @points.last
      straight = Geometry.haversine_distance(first, last)
      
      return 1.0 if straight < 1.0
      
      [real / straight, 1.0].max
    end
    
    # Classificació textual (escala 0-100)
    def classification
      case @icrv2_score
      when 0..10 then "Recta/Còmode (1/10)"
      when 10..30 then "Revirada moderada (2-3/10)"
      when 30..50 then "Bastant revirada (4-5/10)"
      when 50..70 then "Molt revirada (6-7/10)"
      when 70..100 then "Extremadament revirada (8-9/10)"
      else "Crítica (10/10)"
      end
    end
    
    # Resum per pantalla
    def summary
      puts "=" * 50
      puts "📊 ANÀLISI ICRv2"
      puts "=" * 50
      puts "📍 Punts analitzats: #{@points.size}"
      puts "📏 Distància: #{distance_km.round(2)} km"
      puts "〰️ Sinuositat: #{sinuosity.round(2)}"
      puts "↩️ Revolts detectats: #{@turns.size}"
      puts "📈 Revolts/km: #{(@turns.size / distance_km).round(2)}"
      puts "-" * 50
      puts "🎯 ICRv2: #{@icrv2_score.round(0)}"
      puts "🏷️ Classificació: #{classification}"
      puts "=" * 50
    end
    
    # Exportar a Hash
    def to_h
      {
        distance_km: distance_km.round(2),
        sinuosity: sinuosity.round(2),
        irv2: @icrv2_score.round(1),
        turns_count: @turns.size,
        turns_per_km: (@turns.size / distance_km).round(2),
        classification: classification,
        turns: @turns.map(&:to_h)
      }
    end
    
    # Exportar a JSON
    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end

# CLI executable (opcional)
if __FILE__ == $0
  if ARGV.empty?
    puts "Ús: ruby irv2.rb <fitxer.gpx> [sample_distance]"
    exit 1
  end
  
  file_path = ARGV[0]
  sample_distance = (ARGV[1] || 100).to_i
  
  begin
    route = ICRv2::Route.from_gpx(file_path, sample_distance: sample_distance)
      .analyze!(angle_threshold: 30)
    
    route.summary
  rescue ICRv2::Error => e
    puts "❌ Error: #{e.message}"
    exit 1
  rescue => e
    puts "❌ Error inesperat: #{e.message}"
    exit 1
  end
end
