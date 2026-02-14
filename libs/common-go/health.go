package common

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
	Version string `json:"version"`
}

// RegisterHealth adds /health endpoint to router.
func RegisterHealth(r *gin.Engine, service, version string) {
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, HealthResponse{
			Status:  "UP",
			Service: service,
			Version: version,
		})
	})
}
