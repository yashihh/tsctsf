package service

import (
	"fmt"
	"io/ioutil"
	"os"

	logger_util "bitbucket.org/free5gc-team/util/logger"
	"github.com/free5gc/util/httpwrapper"
	"github.com/gin-contrib/cors"
	"github.com/sirupsen/logrus"
	tsctsf_context "github.com/yashihh/tsctsf/internal/context"

	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/pkg/factory"
)

type TsctsfApp struct {
	cfg       *factory.Config
	tsctsfCtx *tsctsf_context.TSCTSFContext
}

func NewApp(cfg *factory.Config) (*TsctsfApp, error) {
	tsctsf := &TsctsfApp{cfg: cfg}
	tsctsf.SetLogEnable(cfg.GetLogEnable())
	tsctsf.SetLogLevel(cfg.GetLogLevel())
	tsctsf.SetReportCaller(cfg.GetLogReportCaller())

	tsctsf_context.Init()
	tsctsf.tsctsfCtx = tsctsf_context.GetSelf()

	return tsctsf, nil
}

func (a *TsctsfApp) SetLogEnable(enable bool) {
	logger.MainLog.Infof("Log enable is set to [%v]", enable)
	if enable && logger.Log.Out == os.Stderr {
		return
	} else if !enable && logger.Log.Out == ioutil.Discard {
		return
	}

	a.cfg.SetLogEnable(enable)
	if enable {
		logger.Log.SetOutput(os.Stderr)
	} else {
		logger.Log.SetOutput(ioutil.Discard)
	}
}

func (a *TsctsfApp) SetLogLevel(level string) {
	lvl, err := logrus.ParseLevel(level)
	if err != nil {
		logger.MainLog.Warnf("Log level [%s] is invalid", level)
		return
	}

	logger.MainLog.Infof("Log level is set to [%s]", level)
	if lvl == logger.Log.GetLevel() {
		return
	}

	a.cfg.SetLogLevel(level)
	logger.Log.SetLevel(lvl)
}

func (a *TsctsfApp) SetReportCaller(reportCaller bool) {
	logger.MainLog.Infof("Report Caller is set to [%v]", reportCaller)
	if reportCaller == logger.Log.ReportCaller {
		return
	}

	a.cfg.SetLogReportCaller(reportCaller)
	logger.Log.SetReportCaller(reportCaller)
}

func (a *TsctsfApp) Start(tlsKeyLogPath string) {
	logger.InitLog.Infoln("Server started")
	// pemPath := factory.TsctsfDefaultCertPemPath
	// keyPath := factory.TsctsfDefaultPrivateKeyPath
	sbi := factory.TsctsfConfig.Configuration.Sbi
	if sbi.Tls != nil {
		// pemPath = sbi.Tls.Pem
		// keyPath = sbi.Tls.Key
	}
	router := logger_util.NewGinWithLogrus(logger.GinLog)

	// policyauthorization.AddService(router)
	// bridgeinfomangement.AddService(router)

	router.Use(cors.New(cors.Config{
		AllowMethods: []string{"GET", "POST", "OPTIONS", "PUT", "PATCH", "DELETE"},
		AllowHeaders: []string{
			"Origin", "Content-Length", "Content-Type", "User-Agent",
			"Referrer", "Host", "Token", "X-Requested-With",
		},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		AllowAllOrigins:  true,
		MaxAge:           86400,
	}))

	HTTPAddr := fmt.Sprintf("%s:%d", factory.TsctsfConfig.Configuration.Sbi.BindingIPv4, factory.TsctsfConfig.Configuration.Sbi.Port)
	server, err := httpwrapper.NewHttp2Server(HTTPAddr, tlsKeyLogPath, router)
	if server == nil {
		logger.InitLog.Error("Initialize HTTP server failed:", err)
		return
	}
	if err != nil {
		logger.InitLog.Warnln("Initialize HTTP server:", err)
	}

	serverScheme := factory.TsctsfConfig.Configuration.Sbi.Scheme
	if serverScheme == "http" {
		err = server.ListenAndServe()
		// } else if serverScheme == "https" {
		// err = server.ListenAndServeTLS(pemPath, keyPath)
	}

	if err != nil {
		logger.InitLog.Fatalf("HTTP server setup failed: %+v", err)
	}
}
