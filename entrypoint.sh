#!/bin/sh
cd "/github/workspace"

changed_files_filename="/tmp/.clang-format-$$.changed.tmp"

git diff --diff-filter=ACMRT --name-only "$PR_BASE".."$PR_HEAD" -- arangod/ lib/ client-tools/ tests/ | grep -e '\.ipp$' -e '\.tpp$' -e '\.cpp$' -e '\.hpp$' -e '\.cc$' -e '\.c$' -e '\.h$' > "$changed_files_filename"

if [ -s "$changed_files_filename" ]; then
  sort "$changed_files_filename" | grep -E "\.\(ipp|tpp|cpp|hpp|cc|c|h\)$" | uniq > "$changed_files_filename.sorted"

  echo 
  echo "about to check formatting on the following files:"
  cat -n "$changed_files_filename.sorted"
  echo
else
  echo "no changes, nothing to do"
  exit 0
fi

# output version info
clang-format --version

# count number of lines in $changed_files_filename
checked=$(wc -l "$changed_files_filename" | cut -d " " -f 1)

# read $changed_files_filename line by line and run clang-format on each filename
echo "checking $checked file(s)..."
formatted=0
passed=0
while read -r file
  do 
    # some .h files are currently misinterpreted as Objective-C files by clang-format,
    # so we pretend that they are .cpp files. this requires piping the input into
    # clang-format as well, unfortunately.
    # force .cpp ending to work around clang-format language interpretation
    nicename="$(basename "$file").cpp"
    git show ":0:$file" | clang-format -Werror -ferror-limit=0 --dry-run --assume-filename="$nicename" -style=file 
    status=$?
    if [[ $status -eq 0 ]]
    then
      # all good
      passed="$((passed+1))"
    elif [[ $status -eq 1 ]]
    then
      echo "file needs reformatting: $file"
      echo
      formatted="$((formatted+1))"
    else
      echo "unknown error formatting file: $file"
      exit 2
    fi

  done < "$changed_files_filename" 

echo

if [[ "$formatted" != "0" ]] 
then
  echo "erroring out because $formatted file(s) still need(s) to be reformatted!!!"
  echo
  exit 1
fi

echo "no errors!"
