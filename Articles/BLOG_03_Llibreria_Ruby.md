# Llibreria Ruby ICRv2: Analitza les teves rutes

## Per als desenvolupadors

Si vols integrar el càlcul de l'ICRv2 a la teva aplicació, hem creat una **llibreria Ruby** completa.

---

## 📦 Instal·lació

```bash
gem install icrv2
```

Al Gemfile:
```ruby
gem 'icrv2', '~> 3.0'
```

---

## 💻 Ús bàsic

```ruby
require 'icrv2'

# Analitzar un tram
resultat = ICRv2.calcular(
  angle: 85,           # angle mitjà de deflexió
  n_corbes: 60,        # nombre de corbes
  tipus: :L,           # :L (local), :P (provincial), :N (nacional)
  km: 14.0,            # longitud del tram
  sinuositat: 2.33     # sinuositat = L_real / L_recta
)

puts resultat[:icrv2]           # => 92
puts resultat[:classificacio]   # => "Extremadament revirada"
```

---

## 🔧 Integració amb Rails

```ruby
# app/models/analisi_ruta.rb
class AnalisiRuta < ApplicationRecord
  def calcular_icrv2!
    resultat = ICRv2.calcular(
      angle: self.angle_mitja,
      n_corbes: self.nombre_corbes,
      tipus: self.tipus_carretera.to_sym,
      km: self.distancia_km,
      sinuositat: self.sinuositat
    )
    
    update!(
      icrv2_score: resultat[:icrv2],
      classificacio: resultat[:classificacio]
    )
  end
end
```

---

## 📊 API de la Llibreria

### `ICRv2.calcular(params)`

Paràmetres:
- `angle` (Float): Angle mitjà de deflexió en graus
- `n_corbes` (Integer): Nombre de corbes significatives
- `tipus` (Symbol): `:L`, `:P` o `:N`
- `km` (Float): Longitud del tram en km
- `sinuositat` (Float): Sinuositat (≥1.0)

Retorna:
```ruby
{
  icrv2: 92,
  classificacio: "Extremadament revirada",
  components: {
    pes_angle: 28.44,
    factor_tipus: 1.08,
    pes_total: 1843.2
  }
}
```

---

## 🛠️ Exemple: Analitzar un GPX

```ruby
require 'icrv2'

# Carregar GPX
gpx = ICRv2::GpxParser.read('ruta.gpx')

# Analitzar
tram = gpx.analitzar_segment(
  from: "Begues",
  to: "Olesa"
)

puts "ICRv2: #{tram.icrv2}"
puts "Classificació: #{tram.classificacio}"
puts "Corbes detectades: #{tram.n_corbes}"
```

---

## 📥 Descarrega

- **GitHub**: `github.com/coopeu/ICRv2`
- **RubyGems**: `gem install icrv2`
- **Documentació**: `docs.motos.cat/icrv2`

---

**Vols contribuir?** T'acceptem pull requests!

*[Tornar al rànquing](/blog/ranking-carreteres-revirades)*
