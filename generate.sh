#!/bin/bash

set -e

# usage:
# ./generate.sh <number of first level subcommands> <number of second level subcommands> <number of flags per command>
#
# creates command of the structure:
#				cmd1
#		sub1	cmd2
# root
#		sub2	cmd1
#				cmd2
FIRST_LEVEL_COMMANDS=${1:-20}
SECOND_LEVEL_COMMANDS=${2:-10}
FLAGS_PER_COMMAND=${3:-10}


rm -rf sub*

function add_flags() {
	if [ "$FLAGS_PER_COMMAND" -gt "0" ]; then
    	echo "flags := cmd.Flags()" >> $1
	fi
    for k in $(seq 1 $FLAGS_PER_COMMAND); do
        echo -e "\tflags.String(\"flag$k\", \"\", \"flag$k help\")" >> $1
        echo -e "\tcmd.RegisterFlagCompletionFunc(\"flag$k\", util.AutocompleteDefault)" >> $1
    done
}

cat > main.go <<- EOF
package main

import (
	"github.com/spf13/cobra"
)

func main() {
	cmd := &cobra.Command{
		Use:  "cobra-perf-test",
		Long: "dummy cli with no real logic",
		RunE: func(cmd *cobra.Command, args []string) error {
			return nil
		},
	}
EOF

#add commands
for i in $(seq 1 $FIRST_LEVEL_COMMANDS); do
    mkdir -p sub$i
    subfile="sub$i/sub$i.go"
    cat > "$subfile" <<- EOF
package sub$i

import (
	"github.com/spf13/cobra"
)

func GetSub$i() *cobra.Command {
	cmd := &cobra.Command{
		Use:  "sub$i",
		Long: "dummy cli with no real logic",
	}
EOF

    echo -e "\tcmd.AddCommand(sub$i.GetSub$i())" >> main.go

    for j in $(seq 1 $SECOND_LEVEL_COMMANDS); do
        cmd="cmd$i$j"
        file="sub$i/cmd$i$j.go"
        cat > "$file" <<- EOF
package sub$i

import (
	"fmt"

    "github.com/Luap99/cobra-perf-test/util"
	"github.com/spf13/cobra"
)

func GetCmd$j() *cobra.Command {
	cmd := &cobra.Command{
		Use:  "cmd$j",
		Long: "dummy cli with no real logic",
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Println(cmd.CommandPath(), args)
			return nil
		},
	}
EOF
        add_flags "$file"
        cat >> "$file" <<- EOF

	return cmd
}
EOF

        echo -e "\tcmd.AddCommand(GetCmd$j())" >> "$subfile"

    done

    cat >> "$subfile" <<- EOF

	return cmd
}
EOF

done

cat >> main.go <<- EOF
    err := cmd.Execute()
	if err != nil {
		panic(err)
	}
}
EOF

# now run goimports to fix the missing imports
goimports -w -srcdir ./... .
