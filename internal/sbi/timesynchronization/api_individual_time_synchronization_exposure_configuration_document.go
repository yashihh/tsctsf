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

// CreateIndividualTimeSynchronizationExposureConfiguration - Craete a new Individual Time Synchronization Exposure Configuration
func CreateIndividualTimeSynchronizationExposureConfiguration(c *gin.Context) {

	c.JSON(http.StatusOK, gin.H{})
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
