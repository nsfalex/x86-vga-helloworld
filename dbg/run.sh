#!/usr/bin/env sh

LOG="/dev/stdout"

qemu_start_dbg() {
  qemu-system-i386 \
    -kernel "$1" \
    -machine pc-i440fx-5.2 \
    -cpu qemu32-v1 \
    -m 500M \
    -S -s \
    -smp 2 \
    -pidfile /tmp/${1}-debug.pid \
    2>&1 >> $LOG
}

qemu_start() {
  qemu-system-i386 \
    -kernel "$1" \
    -machine pc-i440fx-5.2 \
    -cpu qemu32-v1 \
    -m 500M \
    -smp 2 \
    -pidfile /tmp/${1}.pid \
    2>&1 >> $LOG
}

init_log() {
  if [ -f "$LOG" ]; then
    echo -e "\n\n" >> $LOG
  fi
  datetime=`date +%c`
  echo -e "=============== $datetime ===============\n" >> $LOG
}

print_help() {
  echo "Kernel run script for development"
  echo "Usage:"
  echo "$0 [ARGS] <kernel>"
  echo ""
  echo "Where:"
  echo "  kernel:  Multiboot ELF kernel binary"
  echo ""
  echo "Optional Arguments:"
  echo "  -q,  --quiet           Quiet mode"
  echo "  -l,    --log <file>    Log to file"
  echo "  -d,  --debug           Create GDB remote session"
  echo "  -s,    --sym <file>    Symbol file for GDB"
  echo ""
}

main() {
  if [ -z "$1" ]; then
    echo -e "ERROR: Requirements not met"
    print_help
    exit 1
  fi

  target="run"
  kernel=""
  symbol=""

  while [ $1 ]; do 
    case $1 in
      -q|--quiet)
        LOG="/dev/null"
        shift
        ;;

      -l|--log)
        shift
        LOG="$1"
        echo "Logging to $LOG" | tee -a $LOG
        init_log $LOG
        shift
        ;;

      -d|--debug)
        target="dbg"
        shift
        ;;

      -s|--sym)
        shift
        symbol="$1"
        echo "Using symbol file: $symbol" >> $LOG
        shift
        ;;

      *)
        if [ -f "$1" ] && [ -z "$kernel" ]; then
          echo "Using kernel file: $1" >> $LOG
          kernel="$1"
        else
          echo "Unknown argument: $1"
          print_help
          exit 1
        fi
        shift
        ;;
    esac
  done


  [ "$target" = "run" ] && qemu_start "$kernel"
  [ "$target" = "dbg" ] && qemu_start_dbg "$kernel" "$symbol" "$use_tmux"
}

main $@
