!/bin/bash
# Enable strict mode
# set -euo pipefail

# c1grep() {
#   grep "$@" || test $? = 1
# }

# changed_dirs="${CHANGED_FILES_DIR_NAME}"

# # Use ls or find to get the list of files in the directory
# #mapfile -t changed_files_list < <(ls "$changed_files_dir")
# #mapfile -t changed_files_dir_array <<< "$changed_files_dir"
# #mapfile -d "${SEPARATOR}" -t changed_files_dir_array < <(printf "%s" "${CHANGED_DIRS_RAW}")

# # Check each item using a for loop
# # Initialize arrays to store files and directories
# files=()
# dirs=()

# # Loop through each changed file and separate files and directories
# for FILE in "${changed_dirs[@]}"; do
#   if [ -f "$FILE" ]; then
#   # If it's a directory, append to the dirs array
#     dirs+=("$FILE")
#   else
#   # If it's a file, append to the files array
#     files+=("$FILE")
#   fi
# done

# # # Loop through each changed item and separate files and directories
# # for ITEM in "${changed_dirs[@]}"; do
# #   if [ -d "$ITEM" ]; then
# #     # If it's a directory, append to the dirs array
# #     dirs+=("$ITEM")
# #   elif [ -f "$ITEM" ]; then
# #     # If it's a file, append to the files array
# #     files+=("$ITEM")
# #   fi
# # done


# # # Output the results
# # echo "Changed Files:"
# # for file in "${files[@]}"; do
# #   echo "$file"
# # done

# # echo ""
# # echo "Changed Directories:"
# # for dir in "${dirs[@]}"; do
# #   echo "$dir"
# # done

# mapfile -t changed_dirs < <( printf '%s\n' "${dirs[@]}" "${files[@]}")
# echo "changed_dirs=$(jq -cne '{"paths": [$ARGS.positional[]]}' --args "${changed_dirs[@]}")" >> "${GITHUB_OUTPUT}"
# echo "any_changed=${changed_dirs[*]+"true"}" >> "${GITHUB_OUTPUT}"
changed_files="${CHANGED_FILES_DIR_NAME}"
input_files=$(echo "$changed_files" | tr '|' ',')
echo "This is $input_files"
#input_files="${changed_dirs}"

# Arrays to store workflows and actions
workflows=()
actions=()

# Loop through the input files and classify them
IFS=',' read -ra FILES <<< "$input_files"
for file in "${FILES[@]}"; do
  if [[ "$file" == .github/workflows/* ]]; then
    workflows+=("$file")
  elif [[ "$file" == .github/actions/* ]]; then
    actions+=("$file")
  else
    echo "Unknown path: $file"
  fi
done

workflows_json=$(
echo "${workflows[@]}" |  jq -c -R 'split(" ")
  | map({prefix: ("w_" + split("/")[-1] | split(".")[0]), path: (.)})')
echo "$workflows_json"

actions_json=$(
echo "${actions[@]}" | jq -c -R 'split(" ") | map({
   prefix: ("a_" + (split("/")[-2] // "" + "_" + split("/")[-1])),
   path: (split("/") | .[0:-1] | join("/"))})')
echo "$actions_json"

actions_n_workflows_json=$(echo "${workflows_json} ${actions_json}" |  jq -s -c add)
echo "matrix={\"include\":$actions_n_workflows_json}" >> $GITHUB_OUTPUT
echo "any_changed=${actions_n_workflows_json[*]+"true"}" >> "${GITHUB_OUTPUT}"
