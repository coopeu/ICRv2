# ICRv2 - Índex de Carretera Revirada

[![Version](https://img.shields.io/badge/version-3.0-blue.svg)](https://github.com/coopeu/ICRv2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 🏍️ Una llibreria Ruby per calcular la dificultat de conducció de carreteres de muntanya

L'**ICRv2** (Índex de Carretera Revirada) és una fórmula matemàtica que quantifica la "revirada" d'una carretera combinant angle de deflexió, tipus de carretera, nombre de corbes i sinuositat del traçat.

Desenvolupada per [motos.cat](https://motos.cat) i validada amb carreteres reals de Catalunya.

---

## 📊 La Fórmula

```
ICRv2 = [(θ/30)² × F_tipus × N_corbes] / km × Sinuositat² × 10
```

**Components:**
- **θ** = Angle mitjà de deflexió (graus)
- **F_tipus** = Factor segons tipus:
  - **L** (Local/BV/TV): ×1.08
  - **P** (Provincial/C-roads): ×1.0
  - **N** (Nacional): ×0.95
- **N_corbes** = Nombre de corbes (θ ≥ 30°)
- **km** = Longitud
- **Sinuositat** = L_real / L_recta

---

## 📈 Escala d'Interpretació

| ICRv2 | Classificació | Descripció |
|-------|---------------|------------|
| **80-99** | 🔴 Extremadament revirada | Només experts |
| **60-79** | 🟠 Molt revirada | Conducció activa |
| **40-59** | 🟡 Revirada | Atenció necessària |
| **20-39** | 🟢 Poc revirada | Còmoda |
| **0-19** | ⚪ Recta | Sense dificultat |

---

## 🚀 Instal·lació

```bash
gem install ircv2
```

O al Gemfile:
```ruby
gem 'ircv2', '~> 3.0'
```

---

## 💻 Ús

```ruby
require 'icrv2'

# Analitzar un tram
resultat = ICRv2.calcular(
  angle: 85,           # graus
  n_corbes: 60,        # nombre de corbes
  tipus: :L,           # :L, :P o :N
  km: 14.0,            # longitud
  sinuositat: 2.33     # S = L_real / L_recta
)

puts resultat[:icrv2]     # => 92
puts resultat[:classificacio]  # => "Extremadament revirada"
```

---

## 🛣️ Top Carreteres Catalanes

| Tram | ICRv2 | Tipus |
|------|-------|-------|
| Olesa-Avinyonet | **98** | L |
| PN Garraf | **94** | L |
| Begues-Olesa | **92** | L |
| Vallvidrera-Molins | **86** | L |
| Gombrèn-Pobla Lillet | **87** | P |

---

## 📚 Documentació

- [Informe Tècnic Comple](docs/informe_tecnic.md)
- [API Reference](docs/api.md)
- [Exemples](examples/)

---

## 📄 Llicència

MIT License - veure [LICENSE](LICENSE)

---

**Fet amb ❤️ per als amants de les carreteres de muntanya**

*"De la sensació a la xifra"*
