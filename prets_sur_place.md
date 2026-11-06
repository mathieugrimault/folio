# Prêts sur place

## Purpose
Extraction des prêts sur place entre date_min et date_max et optionnellement par l'opérateur 'Totovitch, Jean'.

Format des dates : AAAA-MM-JJ
Format pour opérateur : 'Totovitch, Jean', attention à respecter les majuscules, l'espace et la virgule !

## Parameters

|Parameter|Position|Type|Default value|Sample input|
|---|---|---|---|---|
|param_source|1|TEXT|NULL|ex : Jean, Toto|
|param_mindate|2|TEXT|''|Date min, ex : 2026-10-30|
|param_maxdate|3|TEXT|''|Date max, ex : 2026-10-30|

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
