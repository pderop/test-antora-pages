#!/bin/bash

generate_index() {
  local directory=$1
  local index_path="${directory}/index.html"
  {
    echo "<html><head><title>Index of \"${directory}\"</title></head><body>"
    echo "<h1>Index of \"${directory}\":</h1>"
    echo "<ul>"
    for item in $(ls -dtr "${directory}"/* | sort -V); do
      if [ -d "${item}" ]; then
        local item_name=$(basename "${item}")
        echo "<li><a href=\"${item_name}/\">${item_name}</a></li>"
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
      if [ "${item_name}" = "pdf" ] || [ "${item_name}" = "html" ] || [ "${item_name}" = "javadoc-api" ] || [ "${item_name}" = ".github" ];then
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
