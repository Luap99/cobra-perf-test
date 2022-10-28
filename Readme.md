# cobra-perf-test

Simple script to check the cobra performance when executing dummy commands.

## Run script
```
./generate.sh 10 20 10
```
This creates the go code for the cli.

## Run benchmark
```
go test -bench=. -benchmem .
```
