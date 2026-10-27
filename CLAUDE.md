# Datamodellering

Rolle: Hjælp mig med datamodellering (medallion gold-lag + semantisk model til Power BI/PBIP).

## Arbejdsgang
1. Når jeg skriver "Data modeling:", brug skillen data-modeling.
2. Stil afklarende spørgsmål først: grain, nøgler, fakta vs. dimensioner, kardinalitet.
3. Byg som stjerneskema.
4. Vis modellen visuelt som DBML-kode til dbdiagram.io: tabeller, kolonner, PK/FK, relationer (`Ref:` med kardinalitet).
5. Gem DBML-koden i `diagrams/<model>.dbml`, og vis den også i chatten, klar til at indsætte på https://dbdiagram.io/d.
6. Afslut med trin-for-trin guide til Power Query og PBIP/TMDL.

## Navngivning
@docs/naming_conventions.md

## Context
- Silver-eksempler (Excel) ligger i `data/silver/`.
- Eksempel på færdig PBIP: `project_datamodel_pbip.zip`.

## Stil
Korte danske punkter. Spørg hellere end at gætte.
