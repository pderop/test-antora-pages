#!/bin/bash

generate_index() {
  local directory=$1
  local index_path="${directory}/index.html"
  {
    echo "<html><head><title>Index of \"${directory}\"</title></head><body>"
    echo "<h1>Index of \"${directory}\":</h1>"
    echo "<ul>"
    # Performs a version sort, generally handling version numbers well
    # -t.: Sets the field delimiter to a period (.) for proper version parsing.
    # -k1,1n: Sorts numerically on the first field (major version number).
    # -k2,2n: Sorts numerically on the second field (minor version number).
    # -k3,3V: Sorts version lexicographically on the third field (patch or suffix).
    for item in $(ls -d "${directory}"/* | sort -V -t. -k1,1n -k2,2n -k3,3V); do
      if [ -d "${item}" ]; then
        local item_name=$(basename "${item}")
        if [ "$item_name" == "pdf" ]; then
          pdfname=$(ls $directory/pdf/)
          echo "<li><a href=\"${item_name}/$pdfname\">${item_name}</a></li>"
        else
          echo "<li><a href=\"${item_name}/\">${item_name}</a></li>"
        fi
      fi
    done
    echo "</ul></body></html>"
  } >"${index_path}"
}

generate_html() {
  local directory=$1
  generate_index "${directory}"
  for item in "${directory}"/*; do
    if [ -d "${item}" ] && [ ! -L "${item}" ]; then
      local item_name=$(basename "${item}")
      if [ "${item_name}" = "pdf" ] || [ "${item_name}" = "html" ] || [ "${item_name}" = "javadoc-api" ] || [ "${item_name}" = ".github" ]; then
        continue # Stop recursion for "reference" or "javadoc-api" directories
      fi
      generate_html "${item}"
    fi
  done
}

# Root directory
root_directory=.

# Generate HTML files recursively
generate_html "${root_directory}"
