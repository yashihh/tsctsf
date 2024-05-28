package service

import "github.com/yashihh/tsctsf/pkg/factory"

type TsctsfApp struct {
	cfg *factory.Config
	// pcfCtx *pcf_context.PCFContext
}

func NewApp(cfg *factory.Config) (*TsctsfApp, error) {
	tsctsf := &TsctsfApp{cfg: cfg}
	tsctsf.SetLogEnable(cfg.GetLogEnable())
	tsctsf.SetLogLevel(cfg.GetLogLevel())
	tsctsf.SetReportCaller(cfg.GetLogReportCaller())

	// pcf_context.Init()
	// pcf.pcfCtx = pcf_context.GetSelf()
	return pcf, nil
}
