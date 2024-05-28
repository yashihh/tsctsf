package context

import (
	"sync"
)

var tsnContext *TSCTSFContext

func init() {
	tsnContext = new(TSCTSFContext)
	tsnContext.NwttIndex = make(map[int]int)
}

func TSCTSF_Self() *TSCTSFContext {
	return tsnContext
}

type TSCTSFContext struct {
	AppSessionIdPool sync.Map

	NwttIndex map[int]int
	UpNodes   []UpNode_info
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
