package producer

import (
	"net/http"

	"bitbucket.org/free5gc-team/openapi/models"

	"bitbucket.org/free5gc-team/util/httpwrapper"
	tsctsf_context "github.com/yashihh/tsctsf/internal/context"
	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/internal/sbi/consumer"
	"github.com/yashihh/tsctsf/util"
)

// Npcf_PolicyAuthorization : notify about 5GS Bridge information
func HandleNotification5GSBridgeInfoRequest(request *httpwrapper.Request) *httpwrapper.Response {
	// step 1: log
	logger.PolicyAuthLog.Infof("Handle notify about 5GS Bridge information")
	// step 2: retrieve request
	requestDataType := request.Body.(models.PduSessionTsnBridge)

	// step 3: handle the message
	problemDetails := Notification5GSBridgeInfo(requestDataType)

	// step 4: process the return value from step 3
	if problemDetails != nil {
		// status code is based on SPEC, and option headers
		return httpwrapper.NewResponse(int(problemDetails.Status), nil, problemDetails)
	} else {
		return httpwrapper.NewResponse(http.StatusNoContent, nil, nil)
	}
}

// only dstt in first creation
func Notification5GSBridgeInfo(new_bridge models.PduSessionTsnBridge) *models.ProblemDetails {
	tsctsf_self := tsctsf_context.GetSelf()
	_, exist := tsctsf_self.Bridges[new_bridge.TsnBridgeInfo.BridgeId]
	if !exist {
		var bridge tsctsf_context.Bridge_info
		bridge.Bridge_Id = new_bridge.TsnBridgeInfo.BridgeId
		bridge.Dstt_ports = make(map[uint32]tsctsf_context.Dstt_port_info)
		var dstt_info tsctsf_context.Dstt_port_info
		// dstt_info.Dstt_addr = new_bridge.TsnBridgeInfo.DsttAddr
		dstt_info.Ue_dstt_residence_time = new_bridge.TsnBridgeInfo.DsttResidTime

		bridge.Dstt_ports[new_bridge.TsnBridgeInfo.DsttPortNum] = dstt_info
		bridge.Port_list = append(bridge.Port_list, new_bridge.TsnBridgeInfo.DsttPortNum)
		bridge.Total_port_num = 1

		tsctsf_self.Bridges[new_bridge.TsnBridgeInfo.BridgeId] = bridge
	}

	logger.PolicyAuthLog.Info("Bridge ID : ", new_bridge.TsnBridgeInfo.BridgeId)
	logger.PolicyAuthLog.Info("DS-TT port number : ", new_bridge.TsnBridgeInfo.DsttPortNum)
	// logger.PolicyAuthLog.Info("NW-TT Ethernet port number : ", new_bridge.TsnBridgeInfo.NwttPortNums)
	logger.PolicyAuthLog.Info("UE-DS-TT residence time	: ", new_bridge.TsnBridgeInfo.DsttResidTime)
	logger.PolicyAuthLog.Info("DS-TT MAC address : ", new_bridge.TsnBridgeInfo.DsttAddr)
	logger.PolicyAuthLog.Info("DS-TT PMIC : ", new_bridge.TsnPortManContDstt)
	consumer.HandleAppSessionCreate(new_bridge)
	return nil
}

// Npcf_PolicyAuthorization : notify about 5GS Bridge information
func HandleNotification5GSBridgeUpdate(request *httpwrapper.Request) *httpwrapper.Response {
	// step 1: log
	logger.PolicyAuthLog.Infof("Handle notify about 5GS Bridge information update")
	// step 2: retrieve request
	requestDataType := request.Body.(models.EventsNotification)

	// step 3: handle the message
	problemDetails := Update5GSBridgeInfo(requestDataType)

	// step 4: process the return value from step 3
	if problemDetails != nil {
		// status code is based on SPEC, and option headers
		return httpwrapper.NewResponse(int(problemDetails.Status), nil, problemDetails)
	} else {
		return httpwrapper.NewResponse(http.StatusOK, nil, nil)
	}
}

func Update5GSBridgeInfo(evNotfy models.EventsNotification) *models.ProblemDetails {
	var Id uint64
	if evNotfy.TsnPortManContDstt != nil {
		//logger.PolicyAuthLog.Info("PMIC from DS-TT = ", evNotfy.TsnPortManContDstt)
		Id = util.TTPortResponse(*evNotfy.TsnPortManContDstt)
	}

	if evNotfy.TsnPortManContNwtts != nil {
		//logger.PolicyAuthLog.Info("PMIC from NW-TT = ", evNotfy.TsnPortManContNwtts)
		for i := 0; i < len(evNotfy.TsnPortManContNwtts); i += 1 {
			Id = util.TTPortResponse(evNotfy.TsnPortManContNwtts[i])
		}
	}
	logger.PolicyAuthLog.Infof("Update Bridge ID :[%d] ", Id)

	// tsctsf_self := tsctsf_context.GetSelf()
	// TODO: store nwtt PMIC in TSCTSF

	return nil
}
