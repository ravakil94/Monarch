package common

import (
	"github.com/gin-gonic/gin"
)

const TenantHeader = "X-Tenant-Id"
const tenantKey = "monarch_tenant_id"

// TenantMiddleware extracts tenant ID from request header.
func TenantMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		tenantID := c.GetHeader(TenantHeader)
		if tenantID != "" {
			c.Set(tenantKey, tenantID)
		}
		c.Next()
	}
}

// GetTenantID retrieves tenant ID from gin context.
func GetTenantID(c *gin.Context) string {
	if v, ok := c.Get(tenantKey); ok {
		return v.(string)
	}
	return ""
}
