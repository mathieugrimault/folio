# Requête qualité : holding pas mis dans le Sudoc

## Purpose
Pour une paire emplacement Folio (sans précision) / RCR, sortir les PPN
des notices pour lesquelles il y a un holding Folio qui a cet
emplacement (chercher uniquement sur ceux créés depuis le 1er janvier
2025, pour éviter une recherche sur tout le catalogue d'avant la
migration) mais pas de 930 $5 qui a ce RCR.

## Parameters

|Parameter|Position|Type|Default value|Sample input|
|---|---|---|---|---|
|param_emplacement|1|TEXT|''|Code d'un emplacement, ex : INSPEA|
|param_rcr|2|TEXT|''|RCR, ex : 441092208|

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
