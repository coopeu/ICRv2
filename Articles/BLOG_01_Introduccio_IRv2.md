# ICRv2: L'Índex que Canviarà Com Vius les Rutes en Moto

## De la sensació a la xifra

Tots tenim aquella carretera gravada al cap. Aquella que, quan la nombres en un esmorzar de forquilla, algú diu: *"Uf, aquella és molt revirada"*. Però, què vol dicr exactament "molt revirada"? 

Fins ara, ens basàvem en adjectius. Però a **motos.cat** hem decidit que ja era hora de posar-hi números. Benvinguts a l'era de l'**ICRv2** (Índex de Carretera Revirada): la fórmula que mesura quants revolts hi ha i com de tancats són i quin ritme t'exigeixen.

---

## Per què no en teníem prou amb comptar revolts?

Fins ara, per saber si una ruta era divertida o una tortura per als canells, miràvem el nombre de revolts per quilòmetre. Però siguem sincers: **no és el mateix** una corba de 30° on la moto ni s'inclina, que un angle de 90° i una paella de 180° amb un radi estret que t'obliga a reduicr dos marxes.

Els índexs clàssics es quedaven curts. Per això hem parit l'ICRv2, un algoritme pensat per a motoristes que té en compte:

- **L'angle**: Una corba tancada puntua molt més
- **El radi**: Com més petit és el radi, més "penalitza" l'índex
- **El ritme**: Si les revolts vénen seguides (a menys de 100 metres), l'índex es dispara
- **El "zig-zag" puntua doble**

---

## La ciència darrera l'asfalt: Com funciona l'ICRv2?

L'índex no només mira el mapa; **entén com es condueix**. Hem creat una escala que va del **0 al 100**:

| ICRv2 | Què significa |
|------|---------------|
| **0 - 10** | Passeig marítim o autovia (avorriment total) |
| **10 - 30** | Carretera divertida, bon ritme |
| **30 - 50** | Ja has de mirar-te-les (revirada moderada) |
| **50 - 70** | Territori "revirada". Aquí és on sues dins el casc |
| **70 - 100** | Extremadament revirada. Només per experts |

A diferència d'altres sistemes com RoadCurvature, l'ICRv2 detecta si la carretera és ampla o estreta i si et deixa respirar entre revolt i revolt. Quan l'algoritme diu que una carretera té un ICRv2 de 90, pots estar segur que acabaràs amb els avantbraços calents.

---

## La fórmula (per als tècnics)

```
Pes d'una corba = (angle/30)² × (50/radi)^1.5 × FactorRitme

ICRv2 = (SumaPesos / km) × Sinuositat² × 10
```

**Per què aquests exponents?**
- **(angle/30)²**: Una corba de 90° no és 3× més difícil, és 9× més difícil
- **(50/radi)^1.5**: Una corba de R=30m és més del doble de tècnica que una de R=50m
- **Sinuositat²**: Si una carretera fa un "sudoku" constant, la dificultat es multiplica

---

## Vols provar-ho?

Estem desenvolupant una plataforma on podràs pujar el teu GPX i rebre a l'instant el "diagnòstic" de revirada de la teva sortida. 

**Fes créixer la base de dades!** Tens un tram secret que creus que rebentaria el termòmetre de l'ICRv2? Una carretera secundària a l'Ebre o a l'Empordà que és un tiralínies de revolts? 

**Comparteix els teus GPX amb la comunitat!** Volem mapar cada quilòmetre de Catalunya per saber on es troba el "Flow" definitiu.

T'atreveixes a provar una ruta de 90 d'ICRv2 o ets més de rutes de 40? Deixa el teu comentari!

---

*Segueix llegint:* [El rànquing de les carreteres més revirades de Catalunya](/blog/ranking-carreteres-revirades)
