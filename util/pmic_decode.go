package util

import (
	"bytes"
	"encoding/binary"
	"strconv"

	"bitbucket.org/free5gc-team/openapi/models"
	"github.com/yashihh/tsctsf/internal/logger"
)

var (
	capability = map[string]string{
		// "1":   "txPropagationDelay",                //0001H
		// "2":   "traffic class table",               //0002H
		// "224": "Stream filter instance table",      //00E0H
		// "225": "Stream gate instance table",        //00E01H
		"226": "Supported PTP instance types",      // 0x00E2
		"227": "Supported transport types",         //0x00E3
		"228": "Supported delay mechanisms",        //0x00E4
		"229": "PTP grandmaster capable",           //0x00E5
		"230": "gPTP grandmaster capable",          //0x00E6
		"231": "Supported PTP profiles",            //0x00E7
		"232": "Number of supported PTP instances", //0x00E8
		"233": "PTP instance list",                 //0x00E9
	}
)

func PMICDecodeCapabilityInfo(pmic models.PortManagementContainer) models.PortManagementContainer {
	logger.UtilLog.Tracef("PMIC Decode ready")

	// DS-TT/NW-TT shows capability to TSCTSF
	logger.UtilLog.Info("Deal with Port management capability information")

	container_len := int(pmic.PortManCont[1])<<8 + int(pmic.PortManCont[2]) + 3
	var capability_list []uint16
	for i := 3; i < container_len; i = i + 2 {
		key := uint16(pmic.PortManCont[i])<<8 + uint16(pmic.PortManCont[i+1])
		value, exist := capability[strconv.FormatUint(uint64(key), 10)]

		// if find in capability represent TSCTSF wants it
		if exist {
			logger.UtilLog.Infof("TSCTSF wants [%s] capability", value)
			capability_list = append(capability_list, key)
		} else {
			logger.UtilLog.Info("TSCTSF do not want this capability")
		}
	}

	if len(capability_list) != 0 {
		pmic.PortManCont = PMICCreation(capability_list)
	}
	return pmic
}

func TTPortResponse(pmic models.PortManagementContainer) {
	logger.UtilLog.Info("PMIC Decode ready")
	if pmic.PortManCont[0] == 2 {
		logger.UtilLog.Info("Deal with MANAGE PORT COMPLETE Message")

		capability := bytes.IndexByte(pmic.PortManCont, byte(0x70))
		if capability != -1 {
			logger.UtilLog.Info("Handle port management capability")
		}
		status := bytes.IndexByte(pmic.PortManCont, byte(0x71))
		if status != -1 {
			logger.UtilLog.Info("Handle port status")
			DecodePortStatus(pmic, status)
		}
		update_result := bytes.IndexByte(pmic.PortManCont, byte(0x72))
		if update_result != -1 {
			logger.UtilLog.Info("Handle port update result")
		}
	} else if pmic.PortManCont[0] == 3 {
		logger.UtilLog.Info("Deal with PORT MANAGEMENT NOTIFY Message")
	} else if pmic.PortManCont[0] == 5 {
		logger.UtilLog.Info("Deal with PORT MANAGEMENT NOTIFY COMPLETE Message")
	}
}

// TODO: parameter type
func DecodePortStatus(pmic models.PortManagementContainer, index int) {
	//portstatus_len := int(pmic.PortManCont[index+1])<<8 + int(pmic.PortManCont[index+2]) + 3
	success_read_num := int(pmic.PortManCont[index+3])
	i := index + 4
	for num := 0; num < success_read_num; num += 1 {
		parameter_name := uint16(pmic.PortManCont[i])<<8 + uint16(pmic.PortManCont[i+1])
		parameter_len := int(pmic.PortManCont[i+2])<<8 + int(pmic.PortManCont[i+3])
		switch parameter_name {
		case 1: //0001H
			i = i + 4
			txPropagationDelay := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("txPropagationDelay = ", txPropagationDelay)
			i = i + parameter_len
		case 2: //0002H
			i = i + 4
			traffic_class_table := pmic.PortManCont[i : i+parameter_len]
			logger.UtilLog.Traceln("traffic_class_table = ", traffic_class_table)
			i = i + parameter_len
		case 226: //0x00E2
			i = i + 4
			supportedPTPInstanceTypes := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("Supported PTP instance types = ", supportedPTPInstanceTypes)
			i = i + parameter_len

		case 227: //0x00E3
			i = i + 4
			supportedTransportTypes := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("Supported transport types = ", supportedTransportTypes)
			i = i + parameter_len

		case 228: //0x00E4
			i = i + 4
			supportedDelayMechanisms := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("Supported delay mechanisms = ", supportedDelayMechanisms)
			i = i + parameter_len

		case 229: //0x00E5
			i = i + 4
			ptpGrandmasterCapable := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("PTP grandmaster capable = ", ptpGrandmasterCapable)
			i = i + parameter_len

		case 230: //0x00E6
			i = i + 4
			gptpGrandmasterCapable := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("gPTP grandmaster capable = ", gptpGrandmasterCapable)
			i = i + parameter_len

		case 231: //0x00E7
			i = i + 4
			supportedPTPProfiles := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("Supported PTP profiles = ", supportedPTPProfiles)
			i = i + parameter_len

		case 232: //0x00E8
			i = i + 4
			numberOfSupportedPTPInstances := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("Number of supported PTP instances = ", numberOfSupportedPTPInstances)
			i = i + parameter_len

		case 233: //0x00E9
			i = i + 4
			ptpInstanceList := BytesTo32Uint(pmic.PortManCont[i : i+parameter_len])
			logger.UtilLog.Traceln("PTP instance list = ", ptpInstanceList)
			i = i + parameter_len
		default:
			logger.UtilLog.Info("Skip, do not need it temporarily")
			i = i + 4 + parameter_len
		}
	}
	// tsctsf_self := tsctsf_context.GetSelf()
	// val, exist := tsctsf_self.NwttIndex[int(pmic.PortNum)]
	// if exist {
	// 	tsctsf_self.Bridges[val].Nwtt_txPropagationDelay = txPropagationDelay
	// 	tsctsf_self.Bridges[val].Nwtt_traffic_class_table = traffic_class_table
	// }
	// for i := 0; i < len(tsctsf_self.Bridges); i += 1 {
	// 	val1, exist1 := tsctsf_self.Bridges[i].Dstts[int(pmic.PortNum)]
	// 	if exist1 {
	// 		val1.Dstt_txPropagationDelay = txPropagationDelay
	// 		val1.Dstt_traffic_class_table = traffic_class_table
	// 		tsctsf_self.Bridges[i].Dstts[int(pmic.PortNum)] = val1
	// 	}
	// }
}

// TS24.519 5.2.1 Network-requested Port management procedure PMIC creation on TSCTSF
func PMICCreation(capability_list []uint16) []byte {
	var pmic []byte
	list_len := len(capability_list)

	// 9.1 port management service message type
	pmic = append(pmic, 0b00000001)

	// 9.2 port management list
	// iei (nothing)

	// pmic length : 2 bytes
	len := list_len * 3
	Len := IntToBytes(len)
	pmic = append(pmic, Len[0], Len[1])

	// read capability parameters TSCTSF needed from DS-TT/NW-TT
	for i := 0; i < list_len; i = i + 1 {
		pmic = append(pmic, 0b00000010)
		b := make([]byte, 2)
		binary.BigEndian.PutUint16(b, capability_list[i])
		pmic = append(pmic, b[0], b[1])
	}

	return pmic
}

func IntToBytes(n int) []byte {
	data := uint16(n)
	bytebuf := bytes.NewBuffer([]byte{})
	binary.Write(bytebuf, binary.BigEndian, data)
	return bytebuf.Bytes()
}

func BytesTo32Uint(b []byte) uint32 {
	bytebuf := bytes.NewBuffer(b)
	var value uint32
	binary.Read(bytebuf, binary.BigEndian, &value)
	return value
}
