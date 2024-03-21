#!/bin/bash

KEYWORDS="++ projectreactor auto generated index ++"

generate_index() {

  local directory=$1
  local index_path="${directory}/index.html"
  {
    echo "<html><head><title>Index of \"${directory}\"</title></head><body>"
    echo "<h1>Index of \"${directory}\":</h1>"
    echo "<ul>"

    # Add comment indicating auto-generation and keywords
    echo "<!-- $KEYWORDS -->"

    # Sort directories based on the versions.
    # special dirs "current", "current-SNAPSHOT" are specifically handled so they are displayed a the end of the list.
    # -t.: Sets the field delimiter to a period (.) for proper version parsing.
    # -k1,1n: Sorts numerically on the first field (major version number).
    # -k2,2n: Sorts numerically on the second field (minor version number).
    # -k3,3V: Sorts version lexicographically on the third field (patch or suffix).
    special_dirs=()
    for item in $(ls -d "${directory}"/* | sort -V -t. -k1,1n -k2,2n -k3,3V); do
      if [ -d "${item}" ]; then
        local item_name=$(basename "${item}")

        if [ "$item_name" == "current" ] || [ "$item_name" == "current-SNAPSHOT" ] || [ "$item_name" == "reference" ]; then
          special_dirs+=($item_name)
          continue
        fi

        if [ "$item_name" == "pdf" ]; then
          pdfname=$(ls $directory/pdf/)
          echo "<li><a href=\"${item_name}/$pdfname\">${item_name}</a></li>"
        else
          echo "<li><a href=\"${item_name}/\">${item_name}</a></li>"
        fi
      fi
    done

    for item in "${special_dirs[@]}"; do
      echo "<li><a href=\"${item}/\">${item}</a></li>"
    done
    echo "</ul></body></html>"
  } >"${index_path}"
}

generate_html() {
  local directory=$1
  if [ -f ${directory}/index.html ]; then
    # stop recursion, there is already an index.html in the directory
    return;
  fi

  generate_index "${directory}"
  for item in "${directory}"/*; do
    if [ -d "${item}" ] && [ ! -L "${item}" ]; then
      local item_name=$(basename "${item}")
      if [ "${item_name}" == ".github" ]; then
        continue
      fi
      generate_html "${item}"
    fi
  done
}

# Root directory
root_directory=.

# Clean any previously generated index.html files
find . -name index.html -exec grep -q "$KEYWORDS" {} \; -exec echo "Cleaning {}" \; -exec rm {} \;

# Generate HTML files recursively
generate_html "${root_directory}"
