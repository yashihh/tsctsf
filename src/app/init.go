package app

import (
	"fmt"
	commonConsumerTestLogger "bitbucket.org/free5gc-team/CommonConsumerTestData/logger"
	aperLogger "bitbucket.org/free5gc-team/aper/logger"
	fsmLogger "bitbucket.org/free5gc-team/fsm/logger"
	nasLogger "bitbucket.org/free5gc-team/nas/logger"
	ngapLogger "bitbucket.org/free5gc-team/ngap/logger"
	namfCommLogger "bitbucket.org/free5gc-team/openapi/Namf_Communication/logger"
	namfEventExposureLogger "bitbucket.org/free5gc-team/openapi/Namf_EventExposure/logger"
	nsmfPDUSessionLogger "bitbucket.org/free5gc-team/openapi/Nsmf_PDUSession/logger"
	nudrDataRepositoryLogger "bitbucket.org/free5gc-team/openapi/Nudr_DataRepository/logger"
	openApiLogger "bitbucket.org/free5gc-team/openapi/logger"
	"bitbucket.org/free5gc-team/path_util"

	"github.com/sirupsen/logrus"
	"github.com/urfave/cli"
)

type NetworkFunction interface {
	Initialize(c *cli.Context)
	GetCliCmd() (flags []cli.Flag)
	FilterCli(c *cli.Context) (args []string)
	Exec(*cli.Context) error
	Start()
}

func AppInitializeWillInitialize(cfgPath string) {

	if cfgPath == "" {
		ContextSelf().Path = path_util.Gofree5gcPath("free5gc/config/free5GC.conf")
	} else {
		ContextSelf().Path = path_util.Gofree5gcPath(cfgPath)
	}
	fmt.Println("CommonConfig file:", ContextSelf().Path)

	err := ContextSelf().readFile()
	if err != nil {
		fmt.Println("readFile err   ", err)
	}

	err = ContextSelf().parseConfig()
	if err != nil {
		fmt.Println("parseConfig err   ", err)
	}

	if ContextSelf().Logger.NAS.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.NAS.DebugLevel)
		if err == nil {
			nasLogger.SetLogLevel(level)
		}
	}
	nasLogger.SetReportCaller(ContextSelf().Logger.NAS.ReportCaller)

	if ContextSelf().Logger.FSM.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.FSM.DebugLevel)
		if err == nil {
			fsmLogger.SetLogLevel(level)
		}
	}
	fsmLogger.SetReportCaller(ContextSelf().Logger.FSM.ReportCaller)

	if ContextSelf().Logger.NGAP.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.NGAP.DebugLevel)
		if err == nil {
			ngapLogger.SetLogLevel(level)
		}
	}
	ngapLogger.SetReportCaller(ContextSelf().Logger.NGAP.ReportCaller)

	if ContextSelf().Logger.NamfComm.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.NamfComm.DebugLevel)
		if err == nil {
			namfCommLogger.SetLogLevel(level)
		}
	}
	namfCommLogger.SetReportCaller(ContextSelf().Logger.NamfComm.ReportCaller)

	if ContextSelf().Logger.NamfEventExposure.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.NamfEventExposure.DebugLevel)
		if err == nil {
			namfEventExposureLogger.SetLogLevel(level)
		}
	}
	namfEventExposureLogger.SetReportCaller(ContextSelf().Logger.NamfEventExposure.ReportCaller)

	if ContextSelf().Logger.NsmfPDUSession.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.NsmfPDUSession.DebugLevel)
		if err == nil {
			nsmfPDUSessionLogger.SetLogLevel(level)
		}
	}
	nsmfPDUSessionLogger.SetReportCaller(ContextSelf().Logger.NsmfPDUSession.ReportCaller)

	if ContextSelf().Logger.NudrDataRepository.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.NudrDataRepository.DebugLevel)
		if err == nil {
			nudrDataRepositoryLogger.SetLogLevel(level)
		}
	}
	nudrDataRepositoryLogger.SetReportCaller(ContextSelf().Logger.NudrDataRepository.ReportCaller)

	if ContextSelf().Logger.OpenApi.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.OpenApi.DebugLevel)
		if err == nil {
			openApiLogger.SetLogLevel(level)
		}
	}
	openApiLogger.SetReportCaller(ContextSelf().Logger.OpenApi.ReportCaller)

	if ContextSelf().Logger.Aper.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.Aper.DebugLevel)
		if err == nil {
			aperLogger.SetLogLevel(level)
		}
	}
	aperLogger.SetReportCaller(ContextSelf().Logger.Aper.ReportCaller)

	if ContextSelf().Logger.CommonConsumerTest.DebugLevel != "" {
		level, err := logrus.ParseLevel(ContextSelf().Logger.CommonConsumerTest.DebugLevel)
		if err == nil {
			commonConsumerTestLogger.SetLogLevel(level)
		}
	}
	commonConsumerTestLogger.SetReportCaller(ContextSelf().Logger.CommonConsumerTest.ReportCaller)
}
