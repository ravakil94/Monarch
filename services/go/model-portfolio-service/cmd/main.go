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
		port = "8021"
	}

	r := gin.Default()
	r.Use(common.TenantMiddleware())
	common.RegisterHealth(r, "model-portfolio-service", "0.1.0")

	r.GET("/api/v1/model-portfolios", func(c *gin.Context) {
		tenantID := common.GetTenantID(c)
		c.JSON(200, gin.H{"tenant_id": tenantID, "models": []any{}})
	})

	log.Printf("model-portfolio-service starting on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
