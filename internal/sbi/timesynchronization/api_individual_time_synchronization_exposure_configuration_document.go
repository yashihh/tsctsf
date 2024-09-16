/*
 * Ntsctsf_TimeSynchronization Service API
 *
 * TSCTSF Time Synchronization Service.   © 2022, 3GPP Organizational Partners (ARIB, ATIS, CCSA, ETSI, TSDSI, TTA, TTC).   All rights reserved.
 *
 * API version: 1.0.2
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package TimeSynchronization

import (
	"net/http"

	"bitbucket.org/free5gc-team/openapi"
	"bitbucket.org/free5gc-team/openapi/models"
	"bitbucket.org/free5gc-team/util/httpwrapper"
	"github.com/gin-gonic/gin"
	"github.com/yashihh/tsctsf/internal/logger"
	"github.com/yashihh/tsctsf/internal/sbi/producer"
)

// CreateIndividualTimeSynchronizationExposureConfiguration - Craete a new Individual Time Synchronization Exposure Configuration
func CreateIndividualTimeSynchronizationExposureConfiguration(c *gin.Context) {
	var timeSyncExpoCfg models.TimeSyncExposureConfig
	// step 1: retrieve http request body
	requestBody, err := c.GetRawData()
	if err != nil {
		problemDetail := models.ProblemDetails{
			Title:  "System failure",
			Status: http.StatusInternalServerError,
			Detail: err.Error(),
			Cause:  "SYSTEM_FAILURE",
		}
		logger.TimeSyncCfgLog.Errorf("Get Request Body error: %+v", err)
		c.JSON(http.StatusInternalServerError, problemDetail)
		return
	}

	// step 2: convert requestBody to openapi models
	err = openapi.Deserialize(&timeSyncExpoCfg, requestBody, "application/json")
	if err != nil {
		problemDetail := "[Request Body] " + err.Error()
		rsp := models.ProblemDetails{
			Title:  "Malformed request syntax",
			Status: http.StatusBadRequest,
			Detail: problemDetail,
		}
		logger.TimeSyncCfgLog.Errorln(problemDetail)
		c.JSON(http.StatusBadRequest, rsp)
		return
	}

	// step3 : handle request
	req := httpwrapper.NewRequest(c.Request, timeSyncExpoCfg)
	req.Params["subscriptionId"] = c.Params.ByName("subscriptionId")

	rsp := producer.HandleCreateIndividualTimeSynchronizationExposureConfiguration(req)
	// step4 : response

	for key, val := range rsp.Header {
		c.Header(key, val[0])
	}
	responseBody, err := openapi.Serialize(rsp.Body, "application/json")
	if err != nil {
		logger.TimeSyncCfgLog.Errorln(err)
		problemDetails := models.ProblemDetails{
			Status: http.StatusInternalServerError,
			Cause:  "SYSTEM_FAILURE",
			Detail: err.Error(),
		}
		c.JSON(http.StatusInternalServerError, problemDetails)
	} else {
		c.Data(rsp.Status, "application/json", responseBody)
	}
}

// DeleteIndividualTimeSynchronizationExposureConfiguration - Delete an Individual TimeSynchronization Exposure Configuration
func DeleteIndividualTimeSynchronizationExposureConfiguration(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}

// GetIndividualTimeSynchronizationExposureConfiguration - Reads an existing Individual Time Synchronization Exposure Configuration
func GetIndividualTimeSynchronizationExposureConfiguration(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}

// ReplaceIndividualTimeSynchronizationExposureConfiguration - Replace an individual Time Synchronization Exposure Configuration
func ReplaceIndividualTimeSynchronizationExposureConfiguration(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}
