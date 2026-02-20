# ICRv2 - Índex de Carretera Revirada

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Gem](https://img.shields.io/badge/Ruby-Gem-red.svg)](ircv2_gem/)

> 🏍️ **Metodologia científica per quantificar la dificultat de conducció en carreteres de muntanya**

---

## 📖 Descripció del Projecte

Aquest repositori conté el desenvolupament complet de l'**ICRv2 (Índex de Carretera Revirada v2.0)**, una fórmula matemàtica innovadora que transforma la percepció subjectiva de "carretera revirada" en una mesura objectiva i quantificable.

### Què és l'ICRv2?

L'ICRv2 és una metodologia que combina:
- **Angle de deflexió** de les corbes (θ)
- **Radi de curvatura** (R)
- **Factor de ritme** (corbes consecutives)
- **Sinuositat** del traçat (S)

Per produir un índex de **0 a 100** que indica la dificultat de conducció.

| ICRv2 | Classificació | Percepció del conductor |
|------|---------------|------------------------|
| 0-10 | Recta/Còmode | Conducció relaxada |
| 10-30 | Revirada moderada | Atenció necessària |
| 30-50 | Bastant revirada | Concentració constant |
| 50-70 | Molt revirada | Esforç constant, fatiga ràpida |
| 70-100 | Extremadament revirada | Conducció exigent, només experts |

---

## 📂 Estructura del Repositori

```
ICRv2/
├── README.md                                    # Aquest fitxer
├── Informe_ICRv2_Index_Carretera_Revirada.md   # Informe tècnic complet (v2.0)
├── Informe_ICRv2_Index_Carretera_Revirada_v1.5_backup.md
├── Informe_ICRv2_Index_Carretera_Revirada_v2.md
│
├── Articles/                                    # Articles i publicacions blog
│   ├── Article_IRv2_De_RoadCurvature_a_la_Nova_Metodologia.md
│   ├── BLOG_01_Introduccio_IRv2.md
│   ├── BLOG_02_Ranking_Carreteres.md
│   └── BLOG_03_Llibreria_Ruby.md
│
└── ircv2_gem/                                   # Llibreria Ruby per a càlcul automàtic
    ├── README.md
    └── lib/
        └── ircv2.rb
```

---

## 🎯 Contingut Principal

### 📊 Informe Tècnic Complet

El fitxer [`Informe_ICRv2_Index_Carretera_Revirada.md`](Informe_ICRv2_Index_Carretera_Revirada.md) conté:

1. **Marc teòric** i treballs previs (RoadCurvature, OSM)
2. **Desenvolupament de la fórmula** ICRv2 amb justificació matemàtica
3. **Validació amb 8 trams** de carreteres catalanes reals
4. **Casos pràctics**:
   - **Ruta CollCreueta**: 363 km, 1.014 revolts
   - **Port de La Mussara (T-704)**: Anàlisi detallat amb GPX
5. **Metodologia OSM** per càlcul automàtic
6. **Projecte de desenvolupament** per a plataforma web
7. **Llibreria ICRv2** (especificació tècnica)

**Highlights de resultats:**

| Carretera | Distància | ICRv2 | Classificació |
|-----------|-----------|-------|---------------|
| **Olesa Bonesvalls → Avinyonet** | 12 km | **98** | Extremadament revirada |
| **Begues → Olesa Bonesvalls** | 14 km | **92** | Extremadament revirada |
| **Vallvidrera → Molins** | 16 km | **86** | Extremadament revirada |
| **Gombrèn → Pobla de Lillet** | 25 km | **87** | Extremadament revirada |
| **Port de La Mussara (T-704)** | 12 km | **~82** | Extremadament revirada |
| **Capdevànol → Gombrèn** | 18 km | **79** | Extremadament revirada |

---

## 🧮 La Fórmula ICRv2

### Pes d'una corba individual

```
W_i = (θ_i / 30)² × (50 / R_i)^1.5 × F_ritme

On:
  θ_i = Angle de deflexió (graus)
  R_i = Radi de curvatura (metres)
  F_ritme = 1.5 (corbes <100m), 1.2 (100-200m), 1.0 (>200m)
```

### Índex final

```
ICRv2 = (N_total / L) × S² × 10

On:
  N_total = Σ W_i (suma de pesos)
  L = Longitud del tram (km)
  S = Sinuositat = L_real / L_recta
```

---

## 💻 Implementació: Llibreria Ruby

La carpeta [`ircv2_gem/`](ircv2_gem/) conté una **llibreria Ruby completa** per calcular l'ICRv2 automàticament a partir de fitxers GPX.

### Instal·lació (futura)

```bash
gem install irv2
```

### Exemple d'ús

```ruby
require 'irv2'

# Analitzar una ruta GPX
route = ICRv2::Route.from_gpx('ruta.gpx', sample_distance: 100)
  .analyze!(angle_threshold: 30)

# Mostrar resultats
route.summary
# => ICRv2: 92 | Classificació: Extremadament revirada (9/10)

# Exportar a JSON
File.write('resultats.json', route.to_json)
```

Veure [README de la gem](ircv2_gem/README.md) per més detalls.

---

## 📝 Articles i Publicacions

La carpeta [`Articles/`](Articles/) conté:

1. **Article científic**: "De RoadCurvature a la Nova Metodologia"
2. **Blog posts** per a motos.cat:
   - Introducció a l'ICRv2
   - Rànquing de carreteres revirades
   - Ús de la llibreria Ruby

---

## 🚀 Casos d'Ús

### Per a motoristes i conductors
- **Planificar rutes** segons nivell d'experiència
- **Comparar alternatives** per dificultat
- **Preparar-se mentalment** abans de sortir

### Per a administracions
- **Identificar trams perillosos** objectivament
- **Prioritzar inversions** en senyalització/millores
- **Mesurar eficàcia** de les intervencions

### Per a apps de navegació
- **Oferir rutes alternatives** (còmoda vs divertida)
- **Avisar de dificultat** abans d'iniciar
- **Ajustar temps estimat** segons revirada

---

## 🛠️ Metodologia de Càlcul

### A partir de fitxers GPX

1. **Parsejar GPX** i extreure punts
2. **Re-samplejar** cada 10-20m
3. **Calcular angles** entre trios de punts consecutius
4. **Agrupar corbes** del mateix sentit
5. **Aplicar fórmula** ICRv2
6. **Generar informe**

### A partir d'OpenStreetMap

Utilitzant llibreries com `osmnx` (Python) o `overpass-api` (Ruby):

1. Descarregar geometria de la carretera
2. Processar polilínia
3. Aplicar algoritme de detecció de revolts
4. Calcular ICRv2

Veure **Secció 2.4** de l'informe tècnic per més detalls.

---

## 📊 Resultats Destacats

### Ruta CollCreueta (Cas Pràctic 1)

- **Distància total**: 363 km
- **Revolts (≥45°)**: 1.014
- **Mitjana**: 2.8 revolts/km
- **ICRv2 global**: ~75 (Extremadament revirada)

**Tram més difícil**: Urtx → La Molina → Pobla Lillet
- 72.6 km amb 250 revolts (3.4/km)
- ICRv2: ~86

### Port de La Mussara - T-704 (Cas Pràctic 2)

- **Distància**: 12 km
- **Revolts estimats**: ~30
- **ICRv2**: ~82 (Extremadament revirada)
- **Característica**: 10 ferradures consecutives al tram central

---

## 🔬 Base Científica

L'ICRv2 es basa en treballs previs:

- **RoadCurvature.com** (Adam Franco): Càlcul de curvatura amb OSM
- **Road Tortuosity Index (RTI)**: Suma d'angles per km
- **Highway Safety Manual (HSM)**: Horizontal Curve Density
- **Investigació pròpia**: Integració de factors múltiples i calibració amb dades reals

**Novetat principal**: Combinació de radi, angle, ritme i sinuositat en una sola fórmula calibrada amb percepció subjectiva.

---

## 📈 Projecte de Desenvolupament

L'informe tècnic inclou una **proposta completa** (Secció 11) per desenvolupar una plataforma web integrada a **motos.cat**:

- **Backend**: Python + osmnx + PostGIS
- **Frontend**: React/Vue + Leaflet
- **API pública**: Endpoints per apps de tercers
- **Base de dades**: Catàleg de carreteres catalanes amb ICRv2

**Roadmap**:
1. **MVP** (3 mesos): Motor de càlcul + API bàsica
2. **Beta** (3 mesos): 20-30 trams addicionals + perfils elevació
3. **Producció** (3 mesos): Llançament web + app mòbil

---

## 🧪 Validació

L'ICRv2 ha estat validat amb **8 trams** de carreteres catalanes, comparant la xifra obtinguda amb la percepció subjectiva de conducció:

| Tram | ICRv2 calculat | Percepció (0-10) | Coincidència |
|------|----------------|------------------|--------------|
| Sta. Mª Miralles → Querol | 34 | 7/10 | ✅ |
| Querol → Pont d'Armentera | 52 | 9/10 | ✅ |
| Capdevànol → Gombrèn | 79 | 9/10 | ✅ |
| Gombrèn → Pobla Lillet | 87 | 10/10 | ✅ |

---

## 🤝 Contribucions

Les contribucions són benvingudes! Àrees d'interès:

- **Recollida de dades GPS** de carreteres reals
- **Validació en altres regions** (fora de Catalunya)
- **Millora de l'algoritme** de detecció de corbes
- **Integració amb OSM** (automatització completa)
- **Estudis de correlació** amb accidents

---

## 📄 Llicència

Aquest projecte està sota llicència **MIT** - veure el fitxer LICENSE per més detalls.

---

## 🏍️ Sobre el Projecte

Desenvolupat per l'equip de **motos.cat** amb l'objectiu de proporcionar una eina objectiva i científica per classificar carreteres de muntanya segons la seva dificultat de conducció.

**Estat actual**: Versió 2.0 (Febrer 2026)
- ✅ Fórmula validada
- ✅ Informe tècnic complet
- ✅ Llibreria Ruby funcional
- ⏳ Publicació científica prevista
- ⏳ Plataforma web en desenvolupament

---

## 📚 Referències

1. Highway Safety Manual (HSM), AASHTO, 2010
2. RoadCurvature.com - Adam Franco (https://roadcurvature.com)
3. curvature (GitHub: adamfranco/curvature)
4. osmnx - Llibreria Python per OSM
5. Normativa de disseny de carreteres (NCAT), Ministeri de Foment, 2016

---

## 📞 Contacte

- **Web**: https://motos.cat
- **Email**: dev@motos.cat
- **GitHub**: https://github.com/coopeu/ICRv2

---

<p align="center">
  <b>Fet amb ❤️ per als amants de les carreteres de muntanya</b><br>
  <i>"De la sensació a la xifra"</i>
</p>
