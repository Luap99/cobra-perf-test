package util

import "github.com/spf13/cobra"

func AutocompleteDefault(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	return nil, cobra.ShellCompDirectiveDefault
}
