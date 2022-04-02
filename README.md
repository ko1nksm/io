# io - Summarize I/O resources used by the command

This is I/O version of `time` command and outputs I/O resources used by the command.

## Requirements

- procfs - Linux, etc.

The measurement results are read from the `/proc/<PID>/io`.

## Usage

```sh
# $ base64 -w 999 /dev/urandom | head -n 10000 > data.txt
# $ wc data.txt
#    10000    10000 10000000 data.txt

$ export IOCLEANUP='sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"'
$ export IOWARMUP='sort --version'

$ io sort data.txt > /dev/null
io: cleanup: sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
io: warmup: sort --version

rchar: 10005365
wchar: 10000000
syscr: 124
syscw: 2442
read_bytes: 10002432
write_bytes: 0
cancelled_write_bytes: 0
```

**Note**: See also `env time -v <COMMAND>` (GNU time).

## Environment variables

### IOCLEANUP

Specifies cleanup commands to be executed before measurement is performed.
Typically, it specifies a command to clear the cache.

### IOWARMUP

Specifies the command to be executed before measurement.
This is used to preload the command to be executed, etc., into memory in advance.

## Useless Use of Cat

See https://en.wikipedia.org/wiki/Cat_(Unix)#Useless_use_of_cat

```console
$ base64 -w 999 /dev/urandom | head -n 1000000 > data.txt

$ export IOCLEANUP='sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"'
$ export IOWARMUP='bash /dev/null; sort --version; cat --version'

$ io bash -c 'time sort data.txt > /tmp/output.txt'
io: cleanup: sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
io: warmup: bash /dev/null; sort --version; cat --version

real    0m4.269s
user    0m3.270s
sys     0m1.699s

rchar: 1000014824
wchar: 1000000043
syscr: 149
syscw: 244146
read_bytes: 1000058880
write_bytes: 1000001536
cancelled_write_bytes: 0

$ io bash -c 'time cat data.txt | sort > /tmp/output.txt'
io: cleanup: sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
io: warmup: bash /dev/null; sort --version; cat --version

real    0m8.061s
user    0m2.720s
sys     0m4.083s

rchar: 3959315116
wchar: 3959296043
syscr: 548720
syscw: 730159
read_bytes: 1000214528
write_bytes: 2959458304
cancelled_write_bytes: 1959456768
```

## Comparison with GNU time

```sh
$ base64 -w 999 /dev/urandom | head -n 1000000 > data.txt

$ sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
$ env time -v bash -c 'sort data.txt > /tmp/output.txt'
        Command being timed: "bash -c sort data.txt > /tmp/output.txt"
        User time (seconds): 3.12
        System time (seconds): 1.83
        Percent of CPU this job got: 115%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:04.30
        Average shared text size (kbytes): 0
        Average unshared data size (kbytes): 0
        Average stack size (kbytes): 0
        Average total size (kbytes): 0
        Maximum resident set size (kbytes): 1104064
        Average resident set size (kbytes): 0
        Major (requiring I/O) page faults: 5
        Minor (reclaiming a frame) page faults: 275750
        Voluntary context switches: 3036
        Involuntary context switches: 38
        Swaps: 0
        File system inputs: 1953720
        File system outputs: 1953128
        Socket messages sent: 0
        Socket messages received: 0
        Signals delivered: 0
        Page size (bytes): 4096
        Exit status: 0

$ sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
$ env time -v bash -c 'cat data.txt | sort > /tmp/output.txt'
        Command being timed: "bash -c cat data.txt | sort > /tmp/output.txt"
        User time (seconds): 2.83
        System time (seconds): 4.15
        Percent of CPU this job got: 85%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:08.15
        Average shared text size (kbytes): 0
        Average unshared data size (kbytes): 0
        Average stack size (kbytes): 0
        Average total size (kbytes): 0
        Maximum resident set size (kbytes): 17704
        Average resident set size (kbytes): 0
        Major (requiring I/O) page faults: 6
        Minor (reclaiming a frame) page faults: 5402
        Voluntary context switches: 39994
        Involuntary context switches: 36
        Swaps: 0
        File system inputs: 1953888
        File system outputs: 5780192
        Socket messages sent: 0
        Socket messages received: 0
        Signals delivered: 0
        Page size (bytes): 4096
        Exit status: 0
```
