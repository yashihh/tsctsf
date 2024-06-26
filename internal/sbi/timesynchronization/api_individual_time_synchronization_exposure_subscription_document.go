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

	"github.com/gin-gonic/gin"
)

// DeleteIndividualTimeSynchronizationExposureSubscription - Delete an Individual TimeSynchronization Exposure Subscription
func DeleteIndividualTimeSynchronizationExposureSubscription(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}

// GetIndividualTimeSynchronizationExposureSubscription - Reads an existing Individual Time Synchronization Exposure Subscription
func GetIndividualTimeSynchronizationExposureSubscription(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}

// ReplaceIndividualTimeSynchronizationExposureSubscription - Replace an individual Time Synchronization Exposure Subscription
func ReplaceIndividualTimeSynchronizationExposureSubscription(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}
