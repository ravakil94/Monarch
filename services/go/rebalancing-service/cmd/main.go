package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	common "github.com/ravakil94/Monarch/libs/common-go"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8022"
	}

	r := gin.Default()
	r.Use(common.TenantMiddleware())
	common.RegisterHealth(r, "rebalancing-service", "0.1.0")

	r.POST("/api/v1/rebalance", func(c *gin.Context) {
		tenantID := common.GetTenantID(c)
		c.JSON(202, gin.H{"tenant_id": tenantID, "status": "accepted"})
	})

	log.Printf("rebalancing-service starting on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
