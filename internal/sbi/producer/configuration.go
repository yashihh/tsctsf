package producer

import (
	"fmt"
	"math"
	"net/http"
	"strconv"

	"bitbucket.org/free5gc-team/openapi/models"
	"bitbucket.org/free5gc-team/util/httpwrapper"
	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/pkg/factory"
)

// Creates a new configuration resource to activate time synchronization service.
func HandleCreateIndividualTimeSynchronizationExposureConfiguration(request *httpwrapper.Request) *httpwrapper.Response {
	logger.TimeSyncCfgLog.Infoln("Handle Create Individual Time Synchronization Exposure Configuration")

	newTimeSyncExpoxeCfg := request.Body.(models.TimeSyncExposureConfig)
	subscriptionID := request.Params["subscriptionId"]
	url, problemDetails := TimeSyncExpoCfgCreateProcedure(newTimeSyncExpoxeCfg, subscriptionID)
	header := http.Header{
		"Location": {url},
	}
	if problemDetails != nil {
		return httpwrapper.NewResponse(int(problemDetails.Status), nil, problemDetails)
	} else {
		return httpwrapper.NewResponse(http.StatusCreated, header, newTimeSyncExpoxeCfg)
	}
}

func TimeSyncExpoCfgCreateProcedure(timeSyncExpoCfg models.TimeSyncExposureConfig, subscriptionID string) (string, *models.ProblemDetails) {
	for i, subscription := range factory.TsctsfConfig.Subscriptions {
		if subscription.SubscriptionId == subscriptionID {
			// create a new configuration
			newConfigID, err := getUnusedConfigID()
			if err != nil {
				logger.TimeSyncCfgLog.Warnf(err.Error())

				problemDetails := models.ProblemDetails{
					Title:  "Unsupported request resources",
					Status: http.StatusNotFound,
					Detail: err.Error(),
				}
				return "", &problemDetails
			}
			if subscription.ConfigurationId == "" && subscription.SubscriptionCfg == nil {
				factory.TsctsfConfig.Subscriptions[i].ConfigurationId = newConfigID
				factory.TsctsfConfig.Subscriptions[i].SubscriptionCfg = &timeSyncExpoCfg
			}

			logger.TimeSyncCfgLog.Debugf("ConfigID[%s] with SubscriptionCfg: %+v", factory.TsctsfConfig.Subscriptions[i].ConfigurationId, factory.TsctsfConfig.Subscriptions[i].SubscriptionCfg)
			resourceUri := fmt.Sprintf("ntsctsf-time-sync/v1/subscriptions/%s/configuration/%s", subscriptionID, newConfigID)
			return resourceUri, nil
		}
	}
	logger.TimeSyncCfgLog.Warnf("Update Subscription data of Subscription ID[%s] fail.", subscriptionID)

	//  TODO : problem msg
	problemDetails := &models.ProblemDetails{
		Status: http.StatusBadRequest,
		Cause:  "Malformed request syntax",
	}
	return "", problemDetails

}

func getUnusedConfigID() (string, error) {
	var idx uint32 = 1
	factory.TsctsfConfig.RLock()
	defer factory.TsctsfConfig.RUnlock()

	usedConfigIDs := make(map[uint32]bool)

	// collect exist ConfigID
	for _, subscription := range factory.TsctsfConfig.Subscriptions {
		if subscription.ConfigurationId != "" {
			tempID, err := strconv.Atoi(subscription.ConfigurationId)
			if err != nil {
				return "", err
			}
			usedConfigIDs[uint32(tempID)] = true
		}
	}

	for idx = 1; idx <= math.MaxUint32; idx++ {
		if !usedConfigIDs[idx] {
			return strconv.Itoa(int(idx)), nil
		}
	}
	return "", fmt.Errorf("No available Config ID")
}
