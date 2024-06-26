package context

import (
	"os"
	"strconv"
	"strings"
	"sync"

	"bitbucket.org/free5gc-team/openapi/models"
	"github.com/google/uuid"
	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/pkg/factory"
)

var tsnContext *TSCTSFContext

func Init() {

	config := factory.TsctsfConfig
	logger.InitLog.Infof("tsctsfConfig Info: Version[%s] Description[%s]\n", config.Info.Version, config.Info.Description)
	configuration := config.Configuration
	sbi := configuration.Sbi

	tsnContext = new(TSCTSFContext)
	tsnContext.NfId = uuid.New().String()
	tsnContext.NrfUri = configuration.NrfUri
	tsnContext.UriScheme = factory.TsctsfSbiDefaultScheme  // default uri scheme
	tsnContext.RegisterIPv4 = factory.TsctsfSbiDefaultIPv4 // default localhost
	tsnContext.SBIPort = factory.TsctsfSbiDefaultPort      // default port
	if sbi != nil {
		if sbi.RegisterIPv4 != "" {
			tsnContext.RegisterIPv4 = sbi.RegisterIPv4
		}
		if sbi.Port != 0 {
			tsnContext.SBIPort = sbi.Port
		}

		if sbi.Scheme == "https" {
			tsnContext.UriScheme = models.UriScheme_HTTPS
		} else {
			tsnContext.UriScheme = models.UriScheme_HTTP
		}

		tsnContext.BindingIPv4 = os.Getenv(sbi.BindingIPv4)
		if tsnContext.BindingIPv4 != "" {
			logger.InitLog.Info("Parsing ServerIPv4 address from ENV Variable.")
		} else {
			tsnContext.BindingIPv4 = sbi.BindingIPv4
			if tsnContext.BindingIPv4 == "" {
				logger.InitLog.Warn("Error parsing ServerIPv4 address as string. Using the 0.0.0.0 address as default.")
				tsnContext.BindingIPv4 = "0.0.0.0"
			}
		}
	}
	tsnContext.NrfUri = configuration.NrfUri
	tsnContext.Url = string(tsnContext.UriScheme) + "://" + tsnContext.RegisterIPv4 + ":" + strconv.Itoa(tsnContext.SBIPort)
	serviceNameList := configuration.ServiceNameList

	// context.NfService
	tsnContext.NfService = make(map[models.ServiceName]models.NfService)
	tsnContext.InitNFService(serviceNameList, config.Info.Version)

	tsnContext.NwttIndex = make(map[int]int)

}

func (context *TSCTSFContext) InitNFService(srvNameList []string, version string) {
	tmpVersion := strings.Split(version, ".")
	versionUri := "v" + tmpVersion[0]
	for index, nameString := range srvNameList {
		name := models.ServiceName(nameString)
		context.NfService[name] = models.NfService{
			ServiceInstanceId: strconv.Itoa(index),
			ServiceName:       name,
			Versions: &[]models.NfServiceVersion{
				{
					ApiFullVersion:  version,
					ApiVersionInUri: versionUri,
				},
			},
			Scheme:          context.UriScheme,
			NfServiceStatus: models.NfServiceStatus_REGISTERED,
			ApiPrefix:       context.Url,
			IpEndPoints: &[]models.IpEndPoint{
				{
					Ipv4Address: context.RegisterIPv4,
					Transport:   models.TransportProtocol_TCP,
					Port:        int32(context.SBIPort),
				},
			},
		}
	}
}

type TSCTSFContext struct {
	NfId         string
	SBIPort      int
	RegisterIPv4 string
	BindingIPv4  string
	Url          string
	UriScheme    models.UriScheme
	NrfUri       string
	NfService    map[models.ServiceName]models.NfService

	AppSessionIdPool sync.Map
	NwttIndex        map[int]int
	UpNodes          []UpNode_info
}

type UpNode_info struct {
	UpNode_Id uint64

	Total_port_num int
	Dstt_port_num  uint32
	Nwtt_port_num  uint32

	Port_list  []uint32
	Dstt_ports map[uint32]Dstts_port_info
	Nwtt_ports map[uint32]Nwtt_port_info
	// Bridge_delay             uint32
	// Tsn_traffic_class        uint8
	Ingress_port_num uint8
	Egress_port_num  uint8
	Register         bool
}

type Dstts_port_info struct {
	Register                bool
	Dstt_update             bool
	Dstt_addr               string
	Dstt_txPropagationDelay uint32
	// Dstt_traffic_class_table []uint8
	// Dstt_traffic_class_num   int
	Ingress                bool
	Ue_dstt_residence_time [8]uint8
}

type Nwtt_port_info struct {
	Register    bool
	Nwtt_update bool
	// Nwtt_traffic_class_table []uint8
	// Nwtt_traffic_class_num   int
	Nwtt_txPropagationDelay uint32
	Ingress                 bool
}

// Create new TSN context
func GetSelf() *TSCTSFContext {
	return tsnContext
}

func (a *TSCTSFContext) GetSelfID() string {
	return a.NfId
}
