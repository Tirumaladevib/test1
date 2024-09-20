#!/bin/bash
# Enable strict mode
set -euo pipefail

c1grep() {
  grep "$@" || test $? = 1
}

changed_files_dir="${CHANGED_FILES_DIR_NAME}"

# Use ls or find to get the list of files in the directory
#mapfile -t changed_files_list < <(ls "$changed_files_dir")
#mapfile -t changed_files_dir_array <<< "$changed_files_dir"
#mapfile -d "${SEPARATOR}" -t changed_files_dir_array < <(printf "%s" "${CHANGED_DIRS_RAW}")

# Check each item using a for loop
for item in "${changed_files_dir[@]}"; do
  if [[ -e "$item" ]]; then
    if [[ -f "$item" ]]; then
      echo "$item exists and is a file."
    elif [[ -d "$item" ]]; then
      echo "$item exists and is a directory."
    else
      echo "$item exists but is neither a regular file nor a directory."
    fi
  else
    echo "$item does not exist."
  fi
done

#mapfile -t changed_files < <( printf '%s\n' "${changed_files_dir[@]}" | sort -u | c1grep "\S")
#echo "any_changed=${changed_files_dir[*]+"true"}" >> output.txt
mapfile -t changed_files_dir < <( printf '%s\n' "${changed_files_dir[@]}" | sort -u | c1grep "\S")
echo "changed_files_dir=$(jq -cne '{"paths": [$ARGS.positional[]]}' --args "${changed_files_dir[@]}")" >> "${GITHUB_OUTPUT}"
echo "any_changed=${changed_files_dir[*]+"true"}" >> "${GITHUB_OUTPUT}"
