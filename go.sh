set -m
set -x

# a uuid for the directory in runs/
UUID=$(uuid -v4)

OLDPWD=$(pwd)
NEWROOT=/datadisks/disk1/nfs/projects/nxtest
DIR="${NEWROOT}/runs/${UUID}"

echo "${DIR}"

mkdir -p "${DIR}"
cp test.nf "${DIR}"

cd "${DIR}"

nextflow test.nf -w /datadisks/disk1/nfs/projects/nxtest -with-trace -with-report -with-timeline -with-dag --in_fasta /datadisks/disk1/cifs/code/nxtest/sample.fa &
PID="$!"

while [ -z $(ls -A "${DIR}/.nextflow/cache") ]; do
    sleep 2
done

cd "${NEWROOT}"

# TODO replace this crap with sqlite

cat "${DIR}/.nextflow/history" >> history

# get the "internal uuid" of the run. This is the uuid that is
# in the history file and allows us to link a history entry
# to a trace file
INTERNAL_UUID=$(ls "${DIR}/.nextflow/cache")

mkdir -p traces

mkdir -p pids
echo "$PID" > "pids/${INTERNAL_UUID}.pid"

ln -s "${DIR}/trace.txt" "traces/${INTERNAL_UUID}.trace"

mkdir -p maps
ln -s "${DIR}" "${NEWROOT}/maps/${INTERNAL_UUID}"

fg

rm history

for file in $(ls -tr runs/*/.nextflow/history); do
	cat "${file}" >> history
done

cd "${OLDPWD}"
