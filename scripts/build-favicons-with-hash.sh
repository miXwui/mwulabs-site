#!/bin/bash

# Builds .png and .svg icons with hash and replaces values in files for cache
# busting.
#
# Run from root dir.
#
# Because who needs complicated Webpack when we can have a complicated bash
# script........??? ;) :O :'(

echo "Building icons..."

build_icon() {
  filepath=$1
  build_path=$2

  filename=$(basename "$filepath")
  extension="${filename##*.}"
  file_basename=$(basename $filepath .$extension)

  hash=$(sha256sum $filepath | cut -d ' ' -f1)
  filename_with_hash="$file_basename-$hash.$extension"
  filepath_with_hash="$build_path$filename_with_hash"
  echo "\`$filepath\` -> \`$filepath_with_hash\`" >$(tty)
  cp $filepath $filepath_with_hash
  echo $filename_with_hash
}

ico_filename_with_hash=$(build_icon "./icons/original/favicon.ico" "")
svg_filename_with_hash=$(build_icon "./icons/original/icon.svg" "./icons/")
png_apple_filename_with_hash=$(build_icon "./icons/original/apple-touch-icon.png" "./icons/")
png_192_ico_filename_with_hash=$(build_icon "./icons/original/icon-192.png" "./icons/")
png_512_ico_filename_with_hash=$(build_icon "./icons/original/icon-512.png" "./icons/")
echo "Icons built ✅"

echo -e "\nReplacing icon URLs..."
# HTML
sed -i "s#href=\"/favicon.*\.ico#href=\"/$ico_filename_with_hash#g" index.html
sed -i "s#href=\"/icons/icon.*\.svg#href=\"/icons/$svg_filename_with_hash#g" index.html
sed -i "s#href=\"/icons/apple-touch-icon.*\.png#href=\"/icons/$png_apple_filename_with_hash#g" index.html
echo "index.html ✅"
# manifest.webmanifest
sed -i "s#\"src\": \"/icons/icon-192.*\.png#\"src\": \"/icons/$png_192_ico_filename_with_hash#g" manifest.webmanifest
sed -i "s#\"src\": \"/icons/icon-512.*\.png#\"src\": \"/icons/$png_512_ico_filename_with_hash#g" manifest.webmanifest
echo "manifest.webmanifest ✅"
