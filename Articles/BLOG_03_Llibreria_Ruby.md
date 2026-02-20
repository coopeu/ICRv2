# Llibreria Ruby ICRv2: Analitza les teves rutes com un pro

## Per als desenvolupadors i curiosos del codi

Si vols integrar el càlcul de l'ICRv2 a la teva aplicació o simplement analitzar les teves rutes des de la terminal, hem desenvolupat una **llibreria Ruby** completa i fàcil d'usar.

---

## 🚀 Per què Ruby?

Ruby és el llenguatge perfecte per a aquest projecte perquè:

- **Sintaxi elegant**: Codi llegible i exprésiu
- **Ecosistema Rails**: Si tens motos.cat en Rails, la integració és natural
- **GPX parsing**: Gems com `nokogiri` fan molt fàcil treballar amb XML
- **Tests amb RSpec**: Qualitat assegurada

---

## 📦 Instal·lació

### Com a gem local

```bash
# Clonar el repositori
git clone https://github.com/motoscat/irv2-ruby.git
cd irv2-ruby

# Instal·lar
gem build irv2.gemspec
gem install ./irv2-1.0.0.gem
```

### Al teu Gemfile

```ruby
gem 'irv2', path: './irv2_gem'
# o
# gem 'irv2', git: 'https://github.com/motoscat/irv2-ruby.git'
```

---

## 💻 Ús bàsic

### Analitzar un GPX des de Ruby

```ruby
require 'irv2'

# Carregar i analitzar
route = ICRv2::Route.from_gpx('la_meva_ruta.gpx', sample_distance: 100)
  .analyze!(angle_threshold: 30)

# Veure resultats detallats
route.summary
```

**Sortida:**
```
==================================================
📊 ANÀLISI ICRv2
==================================================
📍 Punts analitzats: 245
📏 Distància: 12.5 km
〰️ Sinuositat: 2.33
↩️ Revolts detectats: 58
📈 Revolts/km: 4.64
--------------------------------------------------
🎯 ICRv2: 92
🏷️ Classificació: Extremadament revirada (9/10)
==================================================
```

### Exportar resultats

```ruby
# A JSON
File.write('resultats.json', route.to_json)

# A Hash per processar
data = route.to_h
puts data[:irv2]        # => 92
puts data[:classification]  # => "Extremadament revirada (9/10)"
```

---

## 🔧 Integració amb Rails

### Model d'anàlisi

```ruby
# app/models/route_analysis.rb
class RouteAnalysis < ApplicationRecord
  has_one_attached :gpx_file
  
  def calculate_irv2!
    return unless gpx_file.attached?
    
    # Descarregar fitxer temporal
    temp_path = Rails.root.join('tmp', "gpx_#{id}.gpx")
    File.binwrite(temp_path, gpx_file.download)
    
    # Analitzar
    analyzer = ICRv2::Route.from_gpx(temp_path.to_s).analyze!
    
    # Guardar resultats
    update!(
      irv2_score: analyzer.irv2_score,
      turns_count: analyzer.turns.count,
      classification: analyzer.classification,
      distance_km: analyzer.distance_km
    )
    
    # Netejar
    File.delete(temp_path)
  end
end
```

### Controlador API

```ruby
# app/controllers/api/routes_controller.rb
class Api::RoutesController < ApplicationController
  def analyze
    @route = RouteAnalysis.find(params[:id])
    @route.calculate_irv2! unless @route.irv2_score
    
    render json: {
      irv2: @route.irv2_score,
      classification: @route.classification,
      distance_km: @route.distance_km,
      turns_count: @route.turns_count
    }
  end
end
```

---

## 📊 Exemple: Comparar dues rutes

```ruby
require 'irv2'

# Analitzar dues rutes
ruta_a = ICRv2::Route.from_gpx('ruta_pirineu.gpx').analyze!
ruta_b = ICRv2::Route.from_gpx('ruta_collserola.gpx').analyze!

# Comparar
puts "PIRINEU vs COLLSEROLA"
puts "=" * 40
puts "Distància: #{ruta_a.distance_km} km vs #{ruta_b.distance_km} km"
puts "ICRv2: #{ruta_a.irv2_score} vs #{ruta_b.irv2_score}"
puts "Revolts: #{ruta_a.turns.count} vs #{ruta_b.turns.count}"
puts "Guanyadora: #{ruta_a.irv2_score > ruta_b.irv2_score ? 'Pirineu' : 'Collserola'}"
```

---

## 🛠️ Funcionalitats avançades

### Personalitzar el mostreig

```ruby
# Mostreig més fi (cada 50m)
route = ICRv2::Route.from_gpx('ruta.gpx', sample_distance: 50)

# Llindar d'angle més baix (més sensible)
route.analyze!(angle_threshold: 25)
```

### Accedicr als detalls dels revolts

```ruby
route.turns.each_with_index do |turn, i|
  puts "Revolt #{i+1}:"
  puts "  Angle: #{turn.angle.round}°"
  puts "  Radi: #{turn.radius.round} m"
  puts "  Direcció: #{turn.direction}"
  puts "  Pes: #{turn.weight.round(2)}"
end
```

---

## 🧪 Tests amb RSpec

```ruby
# spec/irv2_spec.rb
require 'spec_helper'

RSpec.describe ICRv2::Route do
  describe '.from_gpx' do
    it 'carrega un fitxer GPX correctament' do
      route = ICRv2::Route.from_gpx('spec/fixtures/test.gpx')
      expect(route.points).not_to be_empty
    end
  end
  
  describe '#analyze!' do
    it 'calcula un ICRv2 vàlid' do
      route = ICRv2::Route.from_gpx('spec/fixtures/test.gpx').analyze!
      expect(route.irv2_score).to be > 0
      expect(route.irv2_score).to be < 150
    end
  end
end
```

---

## 🌐 Integració amb OpenStreetMap (futur)

Estem treballant per afegicr:

```ruby
# Descarregar carretera per nom
carretera = ICRv2::OSM::Road.find('T-704, Vilaplana')
route = ICRv2::Route.from_osm(carretera).analyze!

# O per coordenades
coords = [[41.234, 2.123], [41.235, 2.124], ...]
route = ICRv2::Route.from_coordinates(coords).analyze!
```

---

## 📥 Descarrega el codi

El codi complet està disponible a:

**GitHub**: `github.com/motoscat/irv2-ruby`  
**Documentació**: `docs.motos.cat/irv2-ruby`

O descarrega directament:

```bash
wget https://motos.cat/downloads/irv2-ruby-v1.0.0.zip
```

---

## 💬 Preguntes freqüents

**Q: Puc usar-ho amb altres llenguatges?**  
R: La llibreria és Ruby, però pots cridar-la via API o usar el CLI.

**Q: És gratis?**  
R: Sí, llicència MIT. Fes el que vulguis amb ella.

**Q: Quin és el GPX mínim que necessito?**  
R: Un track amb almenys 3 punts. Com més dens, millor.

---

**Vols contribuicr?** T'acceptem pull requests! Ajuda'ns a millorar l'algoritme o afegicr noves funcionalitats.

*[Tornar a l'article anterior: El rànquing de carreteres](/blog/ranking-carreteres-revirades)*
