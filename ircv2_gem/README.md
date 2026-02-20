# ICRv2 - Índex de Carretera Revirada per a Carreteres

[![Gem Version](https://badge.fury.io/rb/irv2.svg)](https://badge.fury.io/rb/irv2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.7-red.svg)](https://www.ruby-lang.org/)

> 🏍️ Una llibreria Ruby per calcular la dificultat de conducció de carreteres de muntanya

L'**ICRv2** (Índex de Carretera Revirada) és una fórmula matemàtica que quantifica la "revirada" d'una carretera combinant angle de deflexió, radi de curvatura, ritme de les corbes i sinuositat del traçat.

Desenvolupada per [motos.cat](https://motos.cat) i validada amb carreteres reals de Catalunya.

---

## 📊 Què és l'ICRv2?

L'ICRv2 transforma la **percepció subjectiva** de dificultat en una **xifra objectiva** (0-100):

| ICRv2 | Classificació | Percepció |
|------|---------------|-----------|
| 0-10 | Recta/Còmode | Conducció relaxada |
| 10-30 | Revirada moderada | Atenció necessària |
| 30-50 | Bastant revirada | Concentració constant |
| 50-70 | Molt revirada | Esforç constant |
| 70-100 | Extremadament revirada | Només per experts |

### Top carreteres catalanes (exemples)

- **Olesa → Avinyonet**: ICRv2 = 98 🔥
- **Begues → Olesa**: ICRv2 = 92 🔥
- **Capdevànol → Gombrèn**: ICRv2 = 79
- **Gavà → Begues**: ICRv2 = 61

---

## 🚀 Instal·lació

### Via RubyGems (quan estigui publicada)

```bash
gem install irv2
```

### Via Git

```bash
git clone https://github.com/motoscat/irv2-ruby.git
cd irv2-ruby
bundle install
```

### Al teu Gemfile

```ruby
gem 'irv2', '~> 1.0'
```

---

## 💻 Ús bàsic

### Analitzar un fitxer GPX

```ruby
require 'irv2'

# Carregar i analitzar una ruta
route = ICRv2::Route.from_gpx('ruta.gpx', sample_distance: 100)
  .analyze!(angle_threshold: 30)

# Veure resum
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

# A Hash
data = route.to_h
# => { irv2: 92, classification: "Extremadament revirada (9/10)", ... }
```

---

## 🔧 Integració amb Ruby on Rails

### Model

```ruby
# app/models/route_analysis.rb
class RouteAnalysis < ApplicationRecord
  has_one_attached :gpx_file
  
  def calculate_irv2!
    return unless gpx_file.attached?
    
    temp_path = Rails.root.join('tmp', "gpx_#{id}.gpx")
    File.binwrite(temp_path, gpx_file.download)
    
    analyzer = ICRv2::Route.from_gpx(temp_path.to_s).analyze!
    
    update!(
      irv2_score: analyzer.irv2_score,
      turns_count: analyzer.turns.count,
      classification: analyzer.classification,
      distance_km: analyzer.distance_km
    )
    
    File.delete(temp_path)
  end
end
```

### API Endpoint

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

## 🧮 La Fórmula

```
Pes d'una corba = (angle/30)² × (50/radi)^1.5 × FactorRitme

ICRv2 = (SumaPesos / km) × Sinuositat² × 10
```

**On:**
- **angle**: Grau de deflexió de la corba
- **radi**: Radi de curvatura en metres
- **FactorRitme**: 1.5 si corbes seguides, 1.0 si espaiades
- **Sinuositat**: L_real / L_recta

Per més detalls, consulta l'[Informe Tècnic](https://github.com/motoscat/irv2-ruby/blob/main/docs/informe_tecnic.md).

---

## 🛠️ API de la Llibreria

### Classes principals

#### `ICRv2::Route`

```ruby
# Factory methods
route = ICRv2::Route.from_gpx('fitxer.gpx', sample_distance: 100)
route = ICRv2::Route.from_points(array_de_punts)

# Anàlisi
route.analyze!(angle_threshold: 30)

# Propietats
route.irv2_score      # => 92
route.distance_km     # => 12.5
route.turns.count     # => 58
route.classification  # => "Extremadament revirada (9/10)"
```

#### `ICRv2::Turn`

```ruby
turn = route.turns.first
turn.angle            # => 85.5
turn.radius           # => 35.0
turn.direction        # => :left o :right
turn.weight           # => Pes calculat segons fórmula
```

### Opcions avançades

```ruby
# Mostreig més fi (cada 50m)
route = ICRv2::Route.from_gpx('ruta.gpx', sample_distance: 50)

# Llindar d'angle més baix (més sensible)
route.analyze!(angle_threshold: 25)

# Accedicr a detalls de cada revolt
route.turns.each do |turn|
  puts "#{turn.angle.round}° - R=#{turn.radius.round}m"
end
```

---

## 🧪 Testing

```bash
# Executar tots els tests
bundle exec rspec

# Amb coverage
bundle exec rspec --format documentation
```

---

## 🗺️ Roadmap

- [x] Parser GPX
- [x] Càlcul d'ICRv2
- [x] Integració Rails
- [ ] API d'OpenStreetMap (descarregar carreteres per nom)
- [ ] CLI (executable des de terminal)
- [ ] Visualització de mapes de calor
- [ ] Suport per a KML i FIT
- [ ] Gem publicada a RubyGems

---

## 🤝 Contribuicr

Les contribucions són benvingudes! Si vols millorar l'algoritme, afegicr funcionalitats o corregicr errors:

1. Fes un fork del repositori
2. Crea una branca (`git checkout -b feature/nova-funcionalitat`)
3. Fes commit dels canvis (`git commit -am 'Afegeix nova funcionalitat'`)
4. Fes push a la branca (`git push origin feature/nova-funcionalitat`)
5. Obre un Pull Request

---

## 📚 Recursos

- [Informe Tècnic ICRv2](https://github.com/motoscat/irv2-ruby/blob/main/docs/informe_tecnic.md)
- [Blog motos.cat - Introducció a l'ICRv2](https://motos.cat/blog/introduccio-irv2)
- [Blog motos.cat - Rànquing de carreteres](https://motos.cat/blog/ranking-carreteres-revirades)

---

## 📄 Llicència

Aquest projecte està sota llicència MIT - veure el fitxer [LICENSE](LICENSE) per més detalls.

---

## 🏍️ Sobre motos.cat

Aquesta llibreria ha estat desenvolupada per l'equip de [motos.cat](https://motos.cat), la comunitat de motoristes de Catalunya.

**Contacte:**
- Web: https://motos.cat
- Email: dev@motos.cat
- Twitter: [@motoscat](https://twitter.com/motoscat)

---

<p align="center">
  <b>Fet amb ❤️ per als amants de les carreteres de muntanya</b><br>
  <i>"De la sensació a la xifra"</i>
</p>
