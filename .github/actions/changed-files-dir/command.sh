#!/bin/bash
# Enable strict mode
set -euo pipefail

c1grep() {
  grep "$@" || test $? = 1
}

changed_dirs="${CHANGED_FILES_DIR_NAME}"

# Use ls or find to get the list of files in the directory
#mapfile -t changed_files_list < <(ls "$changed_files_dir")
#mapfile -t changed_files_dir_array <<< "$changed_files_dir"
#mapfile -d "${SEPARATOR}" -t changed_files_dir_array < <(printf "%s" "${CHANGED_DIRS_RAW}")

# Check each item using a for loop
# Initialize arrays to store files and directories
files=()
dirs=()

# Loop through each changed file and separate files and directories
for FILE in "${changed_dirs[@]}"; do
  if [ -f "$FILE" ]; then
  # If it's a directory, append to the dirs array
    dirs+=("$FILE")
  else
  # If it's a file, append to the files array
    files+=("$FILE")
  fi
done

# # Loop through each changed item and separate files and directories
# for ITEM in "${changed_dirs[@]}"; do
#   if [ -d "$ITEM" ]; then
#     # If it's a directory, append to the dirs array
#     dirs+=("$ITEM")
#   elif [ -f "$ITEM" ]; then
#     # If it's a file, append to the files array
#     files+=("$ITEM")
#   fi
# done


# # Output the results
# echo "Changed Files:"
# for file in "${files[@]}"; do
#   echo "$file"
# done

# echo ""
# echo "Changed Directories:"
# for dir in "${dirs[@]}"; do
#   echo "$dir"
# done

mapfile -t changed_dirs < <( printf '%s\n' "${dirs[@]}" "${files[@]}")
echo "changed_dirs=$(jq -cne '{"paths": [$ARGS.positional[]]}' --args "${changed_dirs[@]}")" >> "${GITHUB_OUTPUT}"
echo "any_changed=${changed_dirs[*]+"true"}" >> "${GITHUB_OUTPUT}"
