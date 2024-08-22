package producer

import (
	"net/http"

	"bitbucket.org/free5gc-team/openapi/models"
	"bitbucket.org/free5gc-team/util/httpwrapper"
	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/pkg/factory"
)

// Creates a new configuration resource to activate time synchronization service.
func HandleCreateIndividualTimeSynchronizationExposureConfiguration(request *httpwrapper.Request) *httpwrapper.Response {
	logger.TimeSyncSubLog.Infoln("Handle Create Individual Time Synchronization Exposure Configuration")

	newTimeSyncExpoxeCfg := request.Body.(models.TimeSyncExposureConfig)
	subscriptionID := request.Params["subscriptionId"]
	updatedSubscriptionData, problemDetails := TimeSyncExpoCfgCreateProcedure(newTimeSyncExpoxeCfg, subscriptionID)

	if problemDetails != nil {
		return httpwrapper.NewResponse(int(problemDetails.Status), nil, problemDetails)
	} else {
		return httpwrapper.NewResponse(http.StatusCreated, nil, updatedSubscriptionData)
	}
}

func TimeSyncExpoCfgCreateProcedure(timeSyncExpoCfg models.TimeSyncExposureConfig, subscriptionID string) (*models.TimeSyncExposureConfig, *models.ProblemDetails) {
	for i, subscription := range factory.TsctsfConfig.Subscriptions {
		if subscription.SubscriptionId == subscriptionID {
			factory.TsctsfConfig.Subscriptions[i].SubscriptionCfg = &timeSyncExpoCfg
			logger.TimeSyncSubLog.Debugf("SubscriptionCfg: %+v", subscription.SubscriptionCfg)
			return subscription.SubscriptionCfg, nil
		}
	}
	logger.TimeSyncSubLog.Warnf("Update Subscription data of Subscription ID[%s] fail.", subscriptionID)

	//  TODO : problem msg
	problemDetails := &models.ProblemDetails{
		Status: http.StatusBadRequest,
		Cause:  "Malformed request syntax",
	}
	return nil, problemDetails

}
