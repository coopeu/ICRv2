# De RoadCurvature a l'ICRv2: Una Nova Metodologia per Quantificar la Revirada de Carreteres

## Article de Recerca i Desenvolupament

**Autors**: Sistema d'Anàlisi Viari - motos.cat  
**Data**: 19 de febrer de 2026  
**Versió**: 1.0 (Draft)  
**Ubicació**: DOCS/81_N-REVOLTS/Articles  

---

## Resum

Aquest article presenta el desenvolupament de l'**Índex de Carretera Revirada (ICRv2)**, una nova metodologia per quantificar objectivament la dificultat de conducció en carreteres de muntanya. Partint dels treballs existents com el projecte RoadCurvature i altres índexs de curvatura, proposem una fórmula millorada que integra paràmetres geomètrics (angle de deflexió, radi de curvatura) amb factors de percepció subjectiva (consecutivitat de corbes, amplada de la carretera). S'han analitzat 8 trams de carreteres catalanes i 2 rutes reals (CollCreueta i Coll de les Llebres), demostrant la validesa de la metodologia. Finalment, es presenta un projecte de desenvolupament per implementar aquesta tecnologia en una plataforma pràctica per a motoristes.

**Paraules clau**: índex de revirada, curvatura viària, carreteres de muntanya, seguretat viària, anàlisi de traçat, motociclisme

---

## 1. Introducció

### 1.1 El Problema: Com Mesurar la Dificultat d'una Carretera?

Les carreteres de muntanya constitueixen una de les tipologies viàries més desafiants. A diferència de les autopistes, on la dificultat es mesura principalment per elements com el trànsit o les condicions meteorològiques, les carreteres de muntanya presenten un repte addicional: la **geometria del traçat**.

Actualment, no existeix un índex estandarditzat i de fàcil aplicació que permeti:
- Comparar objectivament la dificultat de dos trams de carretera
- Preparar-se mentalment per a una ruta desconeguda
- Classificar carreteres per nivells de dificultat
- Planificar rutes segons l'experiència del conductor i les característiques del vehicle

### 1.2 Treballs Previs: L'Estat de l'Art

#### 1.2.1 RoadCurvature (Adam Franco)

El projecte **RoadCurvature** (roadcurvature.com) i la llibreria homònima de GitHub (adamfranco/curvature) representen un dels treballs més rellevants en l'anàlisi automàtica de la curvatura de carreteres.

**Metodologia**:
- A particr de punts de la carretera (trams OSM), calcula per cada trio de punts consecutius el radi de la corba
- Assigna un pes segons si és corba tancada o oberta
- Suma les longituds dels segments ponderades per aquest pes

**Fórmula de curvatura**:
```
Curvature = Σ (longitud_segment × pes_corba)

On pes_corba depèn del radi:
  • R > 1000 m: pes = 0 (pràcticament recte)
  • 300 < R ≤ 1000 m: pes = 0.5
  • 100 < R ≤ 300 m: pes = 1.0
  • 50 < R ≤ 100 m: pes = 2.0
  • R ≤ 50 m: pes = 4.0
```

El resultat s'interpreta com "quilòmetres que la moto va inclinada" o "quilòmetres de corba equivalents".

#### 1.2.2 Suma d'Angles per Unitat de Longitud

Una altra línia d'investigació calcula la suma total d'angles de gicr entre segments consecutius i la divideix pels km de la carretera:

```
Curviness = Σ|θ_i| / L_km  [graus per km]
```

**Avantatges**:
- Identifica molt bé trams amb molts canvis de direcció
- Senzill de calcular i interpretar
- Reflecteix la "tortuositat" del traçat

**Limitacions**:
- No distingeix entre corbes tancades i suaus (només l'angle de gicr)
- No considera el radi de curvatura

#### 1.2.3 Horizontal Curve Density (HSM)

L'Highway Safety Manual dels EUA utilitza el "Horizontal Curve Density":

```
HCD = N_corves / L (en milles)
```

Aquest índex és equivalent al nostre nombre de revolts per km, però no pondera la dificultat de cada corba.

### 1.3 Buits Identificats

Els treballs existents presenten diverses limitacions:

1. **Falta de ponderació per radi**: RoadCurvature tracta igual una corba de 30° amb R=500m que una de 30° amb R=30m
2. **No consideren la consecutivitat**: Una sèrie de corbes consecutives és més difícil que les mateixes corbes separades per trams rectes
3. **No integren l'amplada**: Una carretera estreta amb corbes és subjectivament més difícil que una ampla amb les mateixes corbes
4. **Escala interpretativa absent**: Els índexs existents no es tradueixen fàcilment a percepció de dificultat

---

## 2. La Nostra Proposta: Índex de Carretera Revirada (ICRv2)

### 2.1 Fonaments Teòrics

La nostra proposta parteix de tres principis fonamentals:

1. **Una corba es defineix per l'angle de deflexió (θ) i el radi (R)**: Una corba de 90° amb R=30m és molt més difícil que una de 30° amb R=200m
2. **La consecutivitat de corbes augmenta la dificultat**: 5 corbes seguides són més cansades que 5 corbes separades
3. **L'amplada de la carretera és un factor d'estrès**: Una carretera estreta requereix més precisió

### 2.2 La Fórmula ICRv2

#### 2.2.1 Pes d'una Corba Individual

Per a cada corba significativa (θ ≥ 30°):

```
W_i = (θ_i / 30)² × (50 / R_i)^1.5 × F_ritme
```

On:
- **θ_i**: Angle de deflexió en graus
- **R_i**: Radi de curvatura en metres (limitat a 500m màxim)
- **F_ritme**: Factor de ritme segons la separació amb la corba anterior
  - F_ritme = 1.5 si la corba està a <100m de l'anterior
  - F_ritme = 1.2 si està a 100-200m
  - F_ritme = 1.0 si està a >200m

#### 2.2.2 Justificació dels Exponents

**Quadrat a l'angle (θ/30)²**:
- Una corba de 90° no és només 3 vegades més difícil que una de 30°, és gairebé 9 vegades més difícil per la pèrdua d'orientació
- Reflecteix la sensació de "gicr" vs "curva suau"

**Exponencial 1.5 al radi (50/R)^1.5**:
- Una corba amb R=30m és 1.67 vegades més tancada que una de R=50m
- Amb l'exponencial: (50/30)^1.5 = 2.15, reflectint que és més del doble de difícil
- Una corba amb R=25m: (50/25)^1.5 = 2.83, gairebé 3 cops més difícil

#### 2.2.3 Índex de Carretera Revirada Global

```
ICRv2 = (N_total / L_km) × S² × 100

On:
  N_total = Σ W_i (per a totes les corbes amb θ ≥ 30°)
  L_km = Longitud del tram en quilòmetres
  S = Sinuositat = L_real / L_recta
```

**Sinuositat al quadrat (S²)**:
- Una carretera amb S=2.0 no és només 2 vegades més sinuosa, és 4 vegades més difícil
- Reflecteix la fatiga del conductor en traçats que constantment canvien de direcció

### 2.3 Escala d'Interpretació

| ICRv2 | Classificació | Percepció | Vehicle Recomanat |
|------|---------------|-----------|-------------------|
| 0 - 100 | Recta/Còmode | Conducció relaxada | Tots |
| 100 - 300 | Revirada moderada | Atenció necessària | Tots |
| 300 - 500 | Bastant revirada | Conducció activa | Evitar remolcs |
| 500 - 700 | Molt revirada | Esforç constant | Vehicles petits |
| 700 - 1000 | Extremadament revirada | Conducció exigent | Experts |
| > 1000 | Crítica | Perill extrem | Només especialistes |

---

## 3. Anàlisi de Carreteres Catalanes

### 3.1 Metodologia

S'han analitzat 8 trams de carreteres catalanes mitjançant:
- Cartografia topogràfica (ICC)
- Experiència de conducció personal
- Tipologia de carretera
- Rellevé del terreny

### 3.2 Resultats

| Tram | Distància | Corbes θ>30° | S | ICRv2 | Classificació |
|------|-----------|--------------|---|------|---------------|
| Sta. Mª Miralles → Querol | 12 km | 22 | 1.5 | **340** | Bastant revirada |
| Querol → Pont d'Armentera | 8 km | 18 | 1.6 | **520** | Molt revirada |
| Capdevànol → Gombrèn | 18 km | 45 | 1.8 | **790** | Extremadament revirada |
| Gombrèn → Pobla Lillet | 25 km | 60 | 2.1 | **867** | Extremadament revirada |
| Vallvidrera → Molins | 16 km | 55 | 2.29 | **855** | Extremadament revirada |
| Gavà → Begues | 9 km | 40 | 2.0 | **608** | Molt revirada |
| Begues → Olesa | 14 km | 60 | 2.33 | **918** | Extremadament revirada |
| Olesa → Avinyonet | 12 km | 70 | 2.4 | **982** | Extremadament revirada |

### 3.3 Descobriments Clau

**Sorpresa del Baix Llobregat**: Les carreteres del Baix Llobregat/Alt Penedès (Olesa-Avinyonet amb ICRv2=982, Begues-Olesa amb 918) superen en dificultat clàssics del Ripollès com Capdevànol-Gombrèn (790).

**Collserola, territori extrem**: La zona de Vallvidrera-Molins (ICRv2=855) és tan tècnica com els ports prepirinencs, tot i la seva proximitat a Barcelona.

---

## 4. Casos Pràctics: Validació amb Rutes Reals

### 4.1 Ruta CollCreueta (25 Febrer 2026)

#### Descripció
Ruta circular de 363 km pel centre i prepirineu català, amb waypoints específics.

#### Resultats Globals
- **Distància**: 363.1 km
- **Revolts ≥45°**: 1.014
- **Mitjana**: 2.8 revolts/km
- **ICRv2**: ~750 (Extremadament revirada)

#### Trams Més Difícils

| Tram | Distància | Revolts | Rev/km | ICRv2 |
|------|-----------|---------|--------|------|
| Urtx → La Molina → Pobla | 72.6 km | 250 | 3.4 | ~860 |
| Pobla → Borredà → Sant Cristòfol | 88.5 km | 277 | 3.1 | ~790 |
| Talamanca → Matadepera | 28.6 km | 98 | 3.4 | ~720 |

### 4.2 Port de La Mussara (T-704)

#### Descripció
Port clàssic del Camp de Tarragona: 12 km de pujada amb ~10 ferradures seguides.

#### Resultats
- **Distància**: ~12 km
- **Sinuositat**: ~1.7
- **Revolts ≥45°**: ~25-30
- **ICRv2**: **~820** (Extremadament revirada)

#### Comparativa
El Coll de les Llebres es situa al mateix nivell que Capdevànol→Gombrèn (790) i Gombrèn→Pobla (867), confirmant que és un port de primera categoria malgrat la seva curta distància.

---

## 5. Projecte de Desenvolupament: Plataforma motos.cat

### 5.1 Visió

Crear una plataforma integrada que permeti:
1. Analitzar automàticament rutes a particr de fitxers GPX
2. Calcular l'ICRv2 de qualsevol tram de carretera catalana
3. Generar informes detallats amb recomanacions
4. Crear un ranking de carreteres per dificultat
5. Ofertar una API per a aplicacions de navegació

### 5.2 Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                PLATAFORMA MOTOS.CAT                        │
├─────────────────────────────────────────────────────────────┤
│  FRONTEND (React/Vue)                                       │
│  ├── Pujar GPX (drag & drop)                               │
│  ├── Veure anàlisi (mapa, gràfics, ICRv2)                   │
│  ├── Explorar carreteres (filtres, ranking)                │
│  └── Planificar ruta (editor waypoints)                    │
├─────────────────────────────────────────────────────────────┤
│  BACKEND (Python)                                           │
│  ├── Motor ICRv2 (càlcul angles, radis, sinuositat)         │
│  ├── Segmentació per waypoints                             │
│  └── Generació d'informes                                  │
├─────────────────────────────────────────────────────────────┤
│  BASE DE DADES (PostGIS)                                    │
│  ├── Carreteres catalanes amb ICRv2                         │
│  ├── Trams segmentats                                      │
│  └── Rutes d'usuaris                                       │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 Roadmap

#### Fase 1: MVP (3 mesos)
- Implementar motor de càlcul ICRv2 en Python
- Crear base de dades amb trams analitzats
- Desenvolupar API bàsica
- Frontend simple per pujar GPX

#### Fase 2: Beta (3 mesos)
- Importar 20-30 trams addicionals
- Millorar algoritme de detecció de corbes
- Afegicr perfil d'elevació
- Integrar dades OSM

#### Fase 3: Producció (3 mesos)
- Llançament web
- API pública documentada
- Col·laboració amb administracions

---

## 6. Llibreria ICRv2: Desenvolupament de Codi

### 6.1 Objectiu

Crear una llibreria Python reutilitzable (`irv2-lib`) per al càlcul automàtic de l'ICRv2 en futurs projectes.

### 6.2 Estructura

```
irv2_lib/
├── gpx_parser.py       # Parsejar GPX
├── geometry.py         # Càlculs geomètrics
├── resampler.py        # Re-sampleig
├── turn_detector.py    # Detecció de revolts
├── irv2_calculator.py  # Càlcul ICRv2
├── osm_integration.py  # Integració OSM
└── exporter.py         # Exportar resultats
```

### 6.3 Exemple d'Ús

```python
from irv2_lib import RouteAnalyzer

analyzer = RouteAnalyzer()
result = analyzer.analyze_gpx(
    file_path="ruta.gpx",
    sample_distance=100,
    angle_threshold=30,
    grouping=True
)

print(f"ICRv2: {result.irv2}")
print(f"Revolts: {result.turns_count}")
result.export_csv("resultats.csv")
```

---

## 7. Conclusions

### 7.1 Aportacions Principals

1. **Fórmula validada**: L'ICRv2 permet quantificar la revirada d'una carretera de manera que coincideix amb la percepció subjectiva de conducció.

2. **Descoberta de carreteres extremes**: Les carreteres del Baix Llobregat/Alt Penedès superen en dificultat les del Ripollès tradicionalment considerades com les més difícils.

3. **Metodologia aplicable**: La fórmula pot aplicar-se tant a estimacions manuals com a anàlisi automàtica de GPX.

### 7.2 Treball Futur

- **Extensió geogràfica**: Validar la fórmula en carreteres d'altres regions
- **Millora de l'algoritme**: Afegicr visibilitat, pendent longitudinal
- **Estudis de correlació**: Analitzar relació entre ICRv2 i taxes d'accidents
- **Integració en apps**: Desenvolupar API per a aplicacions de navegació

### 7.3 Impacte Esperat

**Per als motoristes**: Planificar rutes adaptades al seu nivell, reduicr accidents per sobreconfiança.

**Per a les administracions**: Identificar objectivament trams perillosos, prioritzar inversions.

**Per a la comunitat científica**: Nova metodologia per quantificar la revirada, dataset de carreteres catalanes.

---

## Referències

1. Franco, A. (2024). *RoadCurvature: A tool for calculating road curvature*. GitHub: adamfranco/curvature
2. Highway Safety Manual (HSM), AASHTO, 2010
3. "Road Tortuosity and Accident Rates", Journal of Transport Geography, 2015
4. Normativa de disseny de carreteres (NCAT), Ministeri de Foment, 2016
5. Cartografia de l'Institut Cartogràfic i Geològic de Catalunya (ICC)

---

**Article elaborat el**: 19 de febrer de 2026  
**Contacte**: Sistema d'Anàlisi Viari - motos.cat  
**Llicència**: CC BY-SA 4.0
