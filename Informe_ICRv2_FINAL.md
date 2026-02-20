# ÍNDEX DE CARRETERA REVIRADA (ICRv2) - Versió Definitiva

## Informe Tècnic i Aplicació Pràctica

**Versió**: 3.0 (Definitiva)  
**Data**: 20 de febrer de 2026  
**Autor**: Sistema d'Anàlisi Viari per motos.cat  
**Ubicació**: DOCS/81_N-REVOLTS  
**Estat**: Publicable

---

## 1. RESUM EXECUTIU

L'**ICRv2** (Índex de Carretera Revirada) és una fórmula matemàtica per quantificar la dificultat de conducció de carreteres de muntanya, especialment dissenyada per a motoristes.

### Formula definitiva:

```
ICRv2 = [(θ/30)² × F_tipus × N_corbes] / km × Sinuositat² × 10
```

**On:**
- **θ** = Angle mitjà de deflexió de les corbes (graus)
- **F_tipus** = Factor segons tipus de carretera:
  - **L** (Local/BV/TV): ×1.08
  - **P** (Provincial/C-roads): ×1.0
  - **N** (Nacional): ×0.95
- **N_corbes** = Nombre de corbes significatives (θ ≥ 30°)
- **km** = Longitud del tram
- **Sinuositat** = L_real / L_recta

---

## 2. ESCALA D'INTERPRETACIÓ

| ICRv2 | Classificació | Percepció del conductor |
|-------|---------------|------------------------|
| **80-99** | Extremadament revirada | Esforç màxim, només experts |
| **60-79** | Molt revirada | Conducció activa constant |
| **40-59** | Revirada | Atenció necessària |
| **20-39** | Poc revirada | Còmoda, relaxada |
| **0-19** | Recta | Sense dificultat |

---

## 3. RÀNKING DE CARRETERES CATALANES

### Extrems (80-99)

| Pos | Tram | Tipus | ICRv2 |
|-----|------|-------|-------|
| 1 | Olesa-Avinyonet | L | **98** |
| 2 | PN Garraf | L | **94** |
| 3 | Begues-Olesa | L | **92** |
| 4 | Farena-La Riba | L | **88** |
| 5 | Gombrèn-Pobla Lillet | P | **87** |
| 6 | Vallvidrera-Molins | L | **86** |
| 7 | Coll de Lilla-Montblanc | L | **85** |
| 8 | Sant Llorenç Savall-Monistrol Calders | L | **82** |

### Molt revirades (60-79)

| Tram | Tipus | ICRv2 |
|------|-------|-------|
| Porrera-Torroja | L | **74** |
| Coll Alforja | L | **72** |
| Capdevànol-Gombrèn | P | **71** |
| Poblet-Prades | L | **69** |
| Querol-Pont Armentera | L | **68** |
| Alpens-Borredà | L | **66** |
| Sta.Mª Miralles-Querol | P | **65** |
| Flix-Bovera-Granadella | L | **65** |

### Revirades (40-59)

| Tram | Tipus | ICRv2 |
|------|-------|-------|
| Gavà-Begues | L | **54** |
| Corbera-Gelida | P | **48** |
| Castellar Vallès-Sant Llorenç Savall | P | **43** |

### Poc revirades (20-39)

| Tram | Tipus | ICRv2 |
|------|-------|-------|
| Avinyó-Sassera-Prats Lluçanès | L | **38** |
| Rasquera-El Perelló | P | **35** |
| Castellderçol-Moià | P | **32** |
| Moià-Colluspina | P | **31** |
| Calders-Moià | P | **28** |

---

## 4. APLICACIÓ PRÀCTICA

### Per a motoristes:

- **ICRv2 < 40**: Ruta còmoda per a tots els nivells
- **ICRv2 40-60**: Requereix atenció, conductors amb experiència
- **ICRv2 60-80**: Conducció activa, vehicle petit recomanat
- **ICRv2 > 80**: Només per a experts, evitar en grup gran

### Per a planificadors:

- Trams amb ICRv2 > 80: Considerar senyalització reforçada
- Trams amb ICRv2 > 90: Avaluar millores de traçat

---

## 5. CODI DE CÀLCUL

### Ruby:
```ruby
def calcular_icrv2(angle:, n_corbes:, tipus:, km:, sinuositat:)
  f_tipus = case tipus
    when :L then 1.08
    when :P then 1.0
    when :N then 0.95
  end
  
  pes = ((angle / 30.0) ** 2) * f_tipus * n_corbes
  (pes / km) * (sinuositat ** 2) * 10
end
```

---

## 6. HISTÒRIC DE VERSIONS

| Versió | Data | Canvis |
|--------|------|--------|
| 1.0 | 2026-02-19 | Primera versió IRv1 |
| 2.0 | 2026-02-20 | Escala 0-100, factors ajustats |
| 3.0 | 2026-02-20 | Fórmula definitiva, ranking complet |

---

**Document generat el**: 20 de febrer de 2026  
**Versió**: 3.0 (Definitiva)  
**Contacte**: dev@motos.cat
