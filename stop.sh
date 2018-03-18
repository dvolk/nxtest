UUID="${1}"

kill $(cat "pids/${1}.pid")
