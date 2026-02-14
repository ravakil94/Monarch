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
		port = "8020"
	}

	r := gin.Default()
	r.Use(common.TenantMiddleware())
	common.RegisterHealth(r, "portfolio-engine-service", "0.1.0")

	r.GET("/api/v1/portfolios", func(c *gin.Context) {
		tenantID := common.GetTenantID(c)
		c.JSON(200, gin.H{"tenant_id": tenantID, "portfolios": []any{}})
	})

	log.Printf("portfolio-engine-service starting on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
