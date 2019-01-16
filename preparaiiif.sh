#!/bin/bash -eu

# questo script:
# 1. prende come input una sottodirectory_parametro contenente tif
# 2. converte le tif in tif piramidali in una nuova sottodirectory creata da questo scrit (_sottodirectory_paramentro)
# 3. crea il manifest (che va eventualmente editato successivamente per aggiungere metadati) con il nome __sottodirectory_parametro.json

#tobedone: controllo parametro passato
#tobedone: vedere se passare i metadati descrittivi iiif da un file esterno

#testata iiif

#identify  -format '%w' immagine.tif per avere la larghezza in pixel
#identify  -format '%h' immagine.tif per avere l'altezza in pixel
#larghezza=`identify -format '%w'` echo $larghezza
#var2=`echo $1 | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]'` per pulire una stringa
sequenza=1

_testata='
{
  "@context": "http://iiif.io/api/presentation/2/context.json",
  "@type": "sc:Manifest",
  "@id": "http://kant.wikibib.it/_'$1'.json",
  "label": "titolo",
  "description": "descrizione",
  "attribution": "Istituzione",
  "sequences": [
    {
      "@type": "sc:Sequence",
      "canvases": [
'
echo "$_testata" >>_$1.json
mkdir _$1

for f in $1/*.tif;
do
        if (($sequenza > 1)); then
          echo "}," >> _$1.json
        fi
        #path=$f
        #file=${path##*/}
        #file=${path##*/}
				convert $f -define tiff:tile-geometry=256x256 ptif:_$f
        echo _$f
        larghezza=`identify  -format '%w' $f`
        echo $larghezza
        altezza=`identify  -format '%h' $f`
        echo $altezza
        ##sostituisce la barra di directory / con %2F in $f che diventa $g (riga 74 e riga 77) ultima modifica (gestione Cantaloupe)
        g=`echo ${f/\//%2F}`

_canvas='
{
"@type": "sc:Canvas",
"@id": "http://kant.wikibib.it/'$sequenza'.json",
"label": "'$sequenza'",
"width": '$larghezza',
"height":'$altezza',
"images": [
{
"@type": "oa:Annotation",
"motivation": "sc:painting",
"on": "http://kant.wikibib.it/'$sequenza'.json",
"resource": {
"@type": "dctypes:Image",
"@id": "http://iiif.wikibib.it/iiif/2/_'$g'/full/full/0/default.jpg",
"service": {
"@context":  "http://iiif.io/api/image/2/context.json",
"@id": "http://iiif.wikibib.it/iiif/2/_'$g'",
"profile": "http://iiif.io/api/image/2/level2.json"
}
}
}
]
'
        echo $_canvas >>  _$1.json
        let "sequenza += 1"

done

_chiusura='
}
]
}
]
}
'
echo $_chiusura >>_$1.json

#qui la formattazione elegante del file json
python -m json.tool _$1.json > __$1.json

#qui da mettere la formattazione elegante del file json
