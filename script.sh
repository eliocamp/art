
thumbifiy () {
    for folder in content/gallery/*/; do
        mogrify -path $folder/thumbs/ -thumbnail 512x512 $folder/imgs/*.png
    done
}


gallery () {
    export folder=$1
    export imgfolder=$2
    export today=$(date '+%Y-%m-%d')

    if [ -d "content/gallery/$folder" ]; then
        echo "La carpeta $folder ya existe!" 1>&2
        return 1
    fi

    # Create gallery folder
    mkdir content/gallery/$folder

    # Create link to image folder
    ln -s "$imgfolder" content/gallery/$folder/imgs

    ## Create thumbnails
    mkdir content/gallery/$folder/thumbs
    mogrify -path content/gallery/$folder/thumbs/ -thumbnail 512x512 content/gallery/$folder/imgs/*.png

    # Create _index.md from template
    envsubst < _index-template.md > content/gallery/$folder/_index.md

    xdg-open content/gallery/$folder
}

build () {
    Rscript -e 'hugodown::hugo_build(dest = "docs", clean = TRUE)'
}
