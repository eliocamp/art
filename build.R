
galleries <- list.files(file.path("content", "gallery"))

populate_gallery <- function(gallery) {
  message("(Re) Creando ", gallery)
  root_folder <- file.path("content", "gallery", gallery)

  config <- yaml::read_yaml(file.path(root_folder, "_index.md"))
  imgs_folder <- file.path(root_folder, "imgs")
  thumbs_folder <- file.path(root_folder, "thumbs")

  # Clean up stuff
  unlink(c(imgs_folder, thumbs_folder), recursive = TRUE)

  # Create img folder with jpgs
  dir.create(imgs_folder, showWarnings = FALSE)

  system(paste("mogrify", "-path", shQuote(imgs_folder), '-format jpg', "-quality 95", shQuote(file.path(config$src, "*.png"))))

  # Create thumbnails
  dir.create(thumbs_folder, showWarnings = FALSE)
  system(paste("mogrify", "-path", shQuote(thumbs_folder), "-thumbnail 512x512 -format jpg -quality 70", shQuote(file.path(imgs_folder, "*.jpg"))))

  # Create splash

  # From https://legacy.imagemagick.org/Usage/distorts/#srt
  size <- '%[fx: w > h ? h : w ]'
  offset_x <- paste0('%[fx: h > w ? 0 : ', config$splash$centre_x, ' < h/2 ? 0 : ', config$splash$centre_x, ' > w - h/2 ? w - h : ', config$splash$centre_x, '/2]')
  offset_y <- paste0('%[fx: w > h ? 0 : ', config$splash$centre_y, ' < w/2 ? 0 : ', config$splash$centre_y, ' > h - w/2 ? h - w : ', config$splash$centre_y, '/2]')
  viewport <- paste0(size, 'x', size, '+', offset_x, '+', offset_y)

  system(
    paste("convert",
          shQuote(file.path(imgs_folder, config$splash$img)),
          "-set option:distort:viewport", shQuote(viewport), "-filter point -distort SRT 0 +repage",
          shQuote(file.path(root_folder, "splash.jpg")))
  )

  system(paste("mogrify -resize 512x521", shQuote(file.path(root_folder, "splash.jpg"))))


}

lapply(galleries, populate_gallery)

hugodown::hugo_build(dest = "docs", clean = TRUE)
hugodown::hugo_start()
