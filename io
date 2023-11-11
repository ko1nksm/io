#!/bin/sh

set -eu
IFS=$(printf '\n\t') && TAB=${IFS#?} LF=${IFS%?} && IFS=" ${TAB}${LF}"

case ${1:-} in
  -h | --help)
    echo "Usage: io [-h | --help] command [arguments]..."
    echo ""
    echo "Reads from storage are not accurate unless the cache is cleared."
    echo "The environment variables IOCLEANUP and IOWARMUP can be used"
    echo "to specify the commands to be used for cleanup and warnup."
    echo ""
    echo "e.g."
    echo "  export IOCLEANUP='sudo sh -c \"echo 1 > /proc/sys/vm/drop_caches\"'"
    echo "  export IOWARMUP='sort --version; cat --version'"
    exit 0
esac

if [ ! -e "/proc/$$/io" ]; then
  echo "io: Not supported. The procfs (/proc/<PID>/io) is required."
  exit 1
fi

if [ "${IOCLEANUP+x}" ]; then
  if [ "$IOCLEANUP" ]; then
    echo "io: cleanup: $IOCLEANUP"
    eval "$IOCLEANUP"
  fi
else
  echo "io: The environment variables IOCLEANUP and IOWARMUP" \
    "can be used to manage the cache."
fi >&2

if [ "${IOWARMUP:-}" ]; then
  echo "io: warmup: $IOWARMUP" >&2
  eval "$IOWARMUP" >/dev/null 2>&1
fi

while IFS="$IFS:" read -r name value; do
  case $name in (*[!a-zA-Z0-9_]*) continue; esac
  case $value in (*[!0-9]*) continue; esac
  eval "io_${name}=\$value"
done < /proc/$$/io

"$@" && ex=0 || ex=$?

echo >&2
while IFS="$IFS:" read -r name value; do
  case $name in (*[!a-zA-Z0-9_]*) continue; esac
  case $value in (*[!0-9]*) continue; esac
  echo "$name: $((value - io_${name}))"
done < /proc/$$/io >&2

exit "$ex"
