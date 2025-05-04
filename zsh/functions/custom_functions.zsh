# Custom functions

# Print content of all files in current directory
catall() {
  # Print the current working directory as the header
  echo -e "\e[1;32mCurrent Directory: $(pwd)\e[0m"
  if [ $# -eq 0 ]; then
    # Default: Show all files
    find . -type f -exec bash -c 'echo -e "\n\n\e[1;34m===== {} =====\e[0m"; bat --style=plain --paging=never "{}"' \;
  else
    # Loop through each extension
    for ext in "$@"; do
      find . -type f -name "*.${ext}" -exec bash -c 'echo -e "\n\n\e[1;34m===== {} =====\e[0m"; bat --style=plain --paging=never "{}"' \;
    done
  fi
}

# Remove all Docker containers
drm() {
    docker rm -f $(docker ps -aq)
}

# Find git logs for a specific author
find_git_logs() {
    # Default value for days is 14 if no argument is provided
    days="${1:-14}"

    # The command with the configurable "days" variable
    find . -name '.git' -type d -prune -exec sh -c '
        repo="{}";
        repo_name=$(echo "$repo" | awk -F/ '\''{print $(NF-1)}'\'');
        cd "$repo/../" &&
        git_log_output=$(git log --author="ravil" --since="${0} day ago" --date=format:"%d.%m.%Y" --pretty=format:"%h - %ad : %s" 2>/dev/null);
        if [ -n "$git_log_output" ]; then
            printf "\nRepository: \033[1;35m$repo_name\033[0m\n$git_log_output\n";
        fi' "$days" \;
}