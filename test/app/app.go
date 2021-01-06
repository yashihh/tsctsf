package app

import (
	"github.com/urfave/cli"
)

type NetworkFunction interface {
	Initialize(c *cli.Context)
	GetCliCmd() (flags []cli.Flag)
	FilterCli(c *cli.Context) (args []string)
	//setLogLevel()
	Exec(*cli.Context) error
	Start()
	Terminate()
}
