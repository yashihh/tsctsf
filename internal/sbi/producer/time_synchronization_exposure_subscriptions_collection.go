package producer

import (
	"fmt"
	"math"
	"net/http"
	"strconv"

	"bitbucket.org/free5gc-team/openapi/models"
	"bitbucket.org/free5gc-team/util/httpwrapper"
	tsctsf_context "github.com/yashihh/tsctsf/internal/context"
	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/pkg/factory"
)

func HandleTimeSynchronizationExposureSubscriptions(request *httpwrapper.Request) *httpwrapper.Response {
	// step 1: log
	logger.TimeSyncSubLog.Infof("Handle Time Synchronization Exposure Subscriptions")
	// step 2: retrieve request
	timeSyncExpoSubscData := request.Body.(models.TimeSyncExposureSubsc)
	// step 3: handle the message
	url, problemDetails := TimeSyncExpoSubscPostProcedure(timeSyncExpoSubscData)

	// step 4: process the return value from step 3
	if problemDetails != nil {
		// status code is based on SPEC, and option headers
		// TODO: Based on TS 29.565 6.1.3.2.3.1, add location header
		return httpwrapper.NewResponse(int(problemDetails.Status), nil, problemDetails)
	}
	header := http.Header{
		"Location": {url},
	}
	return httpwrapper.NewResponse(http.StatusCreated, header, nil)

}

func TimeSyncExpoSubscPostProcedure(new_subsc models.TimeSyncExposureSubsc) (string, *models.ProblemDetails) {
	// store the appSession ID with DNN/S-NSSAI
	var subscription factory.Subscription
	var problemDetails *models.ProblemDetails
	// create a new subscription
	subscID, err := getUnusedSubscriptionID()
	if err != nil {
		logger.TimeSyncSubLog.Warnf(err.Error())

		*problemDetails = models.ProblemDetails{
			Title:  "Unsupported request resources",
			Status: http.StatusNotFound,
			Detail: err.Error(),
		}
		return "", problemDetails
	}

	// assign a subscription correlation ID
	subscription.SubscriptionId = subscID
	subscription.SubscriptionData = new(models.TimeSyncExposureSubsc)
	*subscription.SubscriptionData = new_subsc

	factory.TsctsfConfig.Subscriptions = append(factory.TsctsfConfig.Subscriptions, subscription)
	// TODO : select an expiry time that is equal to or less than the expiry time potentially received in the request;
	// if !subscription.SubscriptionData.Expiry.IsZero() {
	// 	response.Expiry = new(time.Time)
	// 	*response.Expiry = *subscription.SubscriptionData.Expiry
	// }

	tsctsf_self := tsctsf_context.GetSelf()
	dnnSnssai := new_subsc.Dnn + string(new_subsc.Snssai.Sst) + new_subsc.Snssai.Sd
	appSessID, exist := tsctsf_self.AppSessionIdPool.Load(dnnSnssai)
	if !exist {
		logger.TimeSyncSubLog.Errorln("No session found for the given DNN and S-NSSAI.")
		return "", nil
	}
	ID, exist := tsctsf_self.SubscripSession[appSessID.(string)]
	if exist {
		logger.TimeSyncSubLog.Errorln("AF-session has already subscribed with ID :", ID)

	} else {
		tsctsf_self.SubscripSession[appSessID.(string)] = subscID
		logger.TimeSyncSubLog.Infof("New Subscription ID : [%s]", subscID)
		resourceUri := fmt.Sprintf("ntsctsf-time-sync/v1/subscriptions/%s", subscID)
		return resourceUri, nil
	}
	return "", nil
}

func getUnusedSubscriptionID() (string, error) {
	var idx uint32 = 1
	factory.TsctsfConfig.RLock()
	defer factory.TsctsfConfig.RUnlock()
	for _, subscription := range factory.TsctsfConfig.Subscriptions {
		tempID, err := strconv.Atoi(subscription.SubscriptionId)
		if err != nil {
			return "", err
		}
		if uint32(tempID) == idx {
			if idx == math.MaxUint32 {
				return "", fmt.Errorf("No available subscription ID")
			}
			idx = idx + 1
		} else {
			break
		}
	}
	return strconv.Itoa(int(idx)), nil
}
