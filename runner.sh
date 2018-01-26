#!/bin/bash

dataset=$1
boundary=$2

if [ -z "$dataset" ]; then
    echo 'podaj nazwe datasetu'
    exit
fi

# wczytanie danych z $dataset do bazy mongo
mongoimport --db $dataset --collection $dataset --type csv --headerline --file datasets/$dataset.csv
#podział danych na testowe i treningowe
Rscript scripts/R/generate_db.R $dataset

# #algorytm splitbal
# Rscript scripts/R/splitbal_binary.R $dataset 1
# Rscript scripts/R/splitbal_binary.R $dataset 2
# Rscript scripts/R/ensemble.R $dataset 1 2 sum
# Rscript scripts/R/auc.R $dataset ens_1



if [ -z "$boundary" ]; then
    echo 'nie chcesz podac granicy usuwania argumentow? Domyslnie 0.06'
fi

#redukcja atrybutów - Relief
Rscript scripts/R/relief.R $dataset $boundary
#algorytm Splitbal dla zredukowanych danych przez Relief
# Rscript scripts/R/splitbal_binary.R $dataset 1 TRUE
# Rscript scripts/R/splitbal_binary.R $dataset 2 TRUE
# Rscript scripts/R/ensemble.R $dataset 1 2 sum TRUE
# Rscript scripts/R/auc.R $dataset ens_1_reduced TRUE
