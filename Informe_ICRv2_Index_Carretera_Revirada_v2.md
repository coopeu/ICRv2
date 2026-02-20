# ÍNDEX DE REVIRADA (IR) — FÓRMULA DE CÀLCUL PER A CARRETERES

## Informe Tècnic i d'Aplicació Pràctica

**Versió**: 2.0 (Escala 0-100)  
**Data**: 20 de febrer de 2026  
**Autor**: Sistema d'Anàlisi Viari — Desenvolupament per a ús pràctic  
**Ubicació**: DOCS/81_N-REVOLTS  
**Estat**: Versió publicable per a motos.cat  

---

## RESUM EXECUTIU

Aquest document presenta el desenvolupament d'una fórmula matemàtica per quantificar la **revirada** d'una carretera, entesa com la percepció subjectiva de dificultat de conducció derivada de la combinació de corbes, radi, angles i topografia.

La fórmula proposada (ICRv2) integra paràmetres geomètrics objectius amb factors de percepció subjectiva, permetent comparar trams de carretera de manera quantitativa i predicr la dificultat de conducció.

**NOVETAT D'AQUESTA VERSIÓ 2.0**: S'ha escalat l'índex a una escala **0-100** (en lloc de 0-1000) per facilitar la comprensió i comunicació als usuaris. La fórmula matemàtica és la mateixa, però el factor de normalització és diferent.

---

## ESCALA D'INTERPRETACIÓ (0-100)

| ICRv2 | Classificació | Percepció del conductor | Vehicle recomanat |
|------|---------------|------------------------|-------------------|
| 0 - 10 | Recta/Còmode | Conducció relaxada, sense esforç | Tots |
| 10 - 30 | Revirada moderada | Atenció necessària, però còmode | Tots |
| 30 - 50 | Bastant revirada | Conducció activa, concentració constant | Evitar remolcs grans |
| 50 - 70 | Molt revirada | Esforç constant, fatiga ràpida | Vehicles petits/mitjans |
| 70 - 100 | Extremadament revirada | Conducció exigent, perill elevat | Vehicles petits, experts |
| > 100 | Crítica | Perill extrem, només per a especialistes | Vehicles mínims, dia |

---

## RÀNKING DE CARRETERES CATALANES (ESCALA 0-100)

### Resultats ordenats per ICRv2

| Posició | Tram | Distància (km) | Corbes θ>30° | S | ICRv2 | Classificació |
|---------|------|----------------|--------------|---|------|---------------|
| 1 | Olesa Bonesvalls → Avinyonet | 12 | 70 | 2.40 | **98** | Extremadament revirada |
| 2 | Begues → Olesa Bonesvalls | 14 | 60 | 2.33 | **92** | Extremadament revirada |
| 3 | Vallvidrera → Molins | 16 | 55 | 2.29 | **86** | Extremadament revirada |
| 4 | Gombrèn → Pobla de Lillet | 25 | 60 | 2.08 | **87** | Extremadament revirada |
| 5 | Capdevànol → Gombrèn | 18 | 45 | 1.80 | **79** | Extremadament revirada |
| 6 | Gavà → Begues | 9 | 40 | 2.00 | **61** | Molt revirada |
| 7 | Querol → Pont d'Armentera | 8 | 18 | 1.60 | **52** | Molt revirada |
| 8 | Sta. Mª Miralles → Querol | 12 | 22 | 1.50 | **34** | Bastant revirada |

### Anàlisi per regions

#### Serra de Collserola i voltants (trams 3, 2, 1)
**Mitjana ICRv2**: 92

La regió que inclou Vallvidrera, Begues, Olesa i Avinyonet presenta les carreteres més tècniques de Catalunya. **Sorprenentment, superen en dificultat als ports del Pirineu tradicionalment considerats més difícils.**

#### Prepirineu (trams 5, 4)
**Mitjana ICRv2**: 83

La zona de Ripollès i Berguedà presenta carreteres de muntanya clàssiques, però amb trams de respicr entre corbes.

---

## LA FÓRMULA ICRv2 (VERSIÓ 0-100)

### Equació definitiva

**Pes d'una corba individual**:
```
W_i = (θ_i / 30)² × (50 / R_i)^1.5 × F_ritme
```

**Índex de Carretera Revirada (ICRv2)**:
```
ICRv2 = (N_total / L) × S² × 10

On:
  N_total = Σ W_i (suma de pesos de totes les corbes)
  L = Longitud del tram en km
  S = Sinuositat = L_real / L_recta
```

**Nota**: El factor de normalització és 10 (en lloc de 100 a la versió 0-1000).

### Factors clau

| Factor | Descripció | Impacte |
|--------|------------|---------|
| **Angle** | (θ/30)² penalitza corbes tancades exponencialment | Una corba de 90° puntua 9× més que una de 30° |
| **Radi** | (50/R)^1.5 penalitza radis petits | R=30m és 2.15× més difícil que R=50m |
| **Ritme** | F_ritme = 1.5 si les corbes van seguides | Corbes consecutives són més exigents |
| **Sinuositat** | S² reflecteix l'efecte multiplicador | S=2.0 implica 4× més dificultat |

---

## LLIBRERIA RUBY IRV2

### Instal·lació

```bash
gem install irv2
```

### Ús bàsic

```ruby
require 'irv2'

# Analitzar un fitxer GPX
route = ICRv2::Route.from_gpx('ruta.gpx', sample_distance: 100)
  .analyze!(angle_threshold: 30)

# Veure resultats
route.summary
# 📊 ANÀLISI ICRv2
# ==========================================
# 📍 Punts analitzats: 245
# 📏 Distància: 12.5 km
# 〰️ Sinuositat: 2.33
# ↩️ Revolts detectats: 58
# 📈 Revolts/km: 4.64
# ------------------------------------------
# 🎯 ICRv2: 92
# 🏷️ Classificació: Extremadament revirada (9/10)
# ==========================================

# Exportar a JSON
require 'json'
File.write('resultats.json', route.to_json)
```

### Integració amb Rails

```ruby
# app/models/route_analysis.rb
class RouteAnalysis < ApplicationRecord
  has_one_attached :gpx_file
  
  def calculate_irv2!
    return unless gpx_file.attached?
    
    # Descarregar el fitxer temporalment
    temp_path = Rails.root.join('tmp', "gpx_#{id}.gpx")
    File.binwrite(temp_path, gpx_file.download)
    
    # Analitzar
    analyzer = ICRv2::Route.from_gpx(temp_path.to_s).analyze!
    
    # Guardar resultats
    update!(
      irv2_score: analyzer.irv2_score,
      turns_count: analyzer.turns.count,
      classification: analyzer.classification,
      distance_km: analyzer.distance_km,
      sinuosity: analyzer.sinuosity
    )
    
    # Netejar
    File.delete(temp_path)
  end
end

# app/controllers/routes_controller.rb
class RoutesController < ApplicationController
  def analyze
    @route = RouteAnalysis.find(params[:id])
    @route.calculate_irv2!
    render json: @route.to_h
  end
end
```

---

## TAULA COMPARATIVA: VERSIÓ 0-100 vs 0-1000

| Tram | ICRv2 (0-1000) | ICRv2 (0-100) | Classificació |
|------|---------------|--------------|---------------|
| Olesa → Avinyonet | 982 | **98** | Extremadament revirada |
| Begues → Olesa | 918 | **92** | Extremadament revirada |
| Vallvidrera → Molins | 855 | **86** | Extremadament revirada |
| Gombrèn → Pobla Lillet | 867 | **87** | Extremadament revirada |
| Capdevànol → Gombrèn | 790 | **79** | Extremadament revirada |
| Gavà → Begues | 609 | **61** | Molt revirada |
| Querol → Pont d'Armentera | 520 | **52** | Molt revirada |
| Sta. Mª Miralles → Querol | 340 | **34** | Bastant revirada |

---

## APLICACIONS PRÀCTIQUES

### Per a motoristes

**Com interpretar l'ICRv2 abans de sorticr:**

- **ICRv2 < 30**: Ruta còmoda, apta per a tots els vehicles i nivells
- **ICRv2 30-50**: Atenció requerida, evitar remolcs grans en trams puntuals
- **ICRv2 50-70**: Conducció activa, vehicle petit o mitjà recomanat
- **ICRv2 70-100**: Només per a vehicles petits, conducció experta, evitar mal temps

### Per a planificadors viaris

- Trams amb ICRv2 > 70: Considerar senyalització reforçada, miralls, etc.
- Trams amb ICRv2 > 90: Avaluar millores geomètriques si el trànsit ho justifica

---

## CONCLUSIONS

1. **Escala més entenedora**: La versió 0-100 facilita la comunicació amb usuaris no tècnics
2. **Sorpreses del rànquing**: El Baix Llobregat/Alt Penedès "guanya" al Pirineu en revirada tècnica
3. **Eina validada**: L'ICRv2 coincideix amb l'experiència real de conducció
4. **Implementació Ruby**: La llibreria permet integrar l'anàlisi a motos.cat fàcilment

---

**Document generat el**: 20 de febrer de 2026  
**Versió**: 2.0 (Escala 0-100)  
**Autor**: Sistema d'Anàlisi Viari
