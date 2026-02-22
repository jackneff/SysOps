# Web Monitoring

Comprehensive web endpoint testing for sysadmins and developers.

## Overview

This module provides testing capabilities for various web service technologies:
- **REST APIs** - Modern web services
- **SOAP APIs** - Legacy enterprise services
- **Microsoft Graph** - Microsoft 365 APIs
- **GraphQL** - Query-based APIs

## Quick Start

### Basic Usage

```powershell
# Test REST API endpoint
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -Method GET

# Test SOAP endpoint
.\Test-SoapEndpoint.ps1 -Url "https://soap.example.com/service" -Action "GetUser"

# Test Microsoft Graph
.\Test-GraphEndpoint.ps1 -Url "https://graph.microsoft.com/v1.0/users" -TenantId "xxx" -ClientId "xxx" -ClientSecret "xxx"

# Test GraphQL
.\Test-GraphQlEndpoint.ps1 -Url "https://api.example.com/graphql" -Query "{ users { id name } }"

# Run all configured endpoints
.\Test-BatchRequests.ps1
```

---

## Endpoint Technologies Explained

### REST (Representational State Transfer)

**What it is:**
REST is the most common web API style. Uses standard HTTP methods (GET, POST, PUT, PATCH, DELETE) and returns JSON or XML.

**Where you'll encounter it:**
- Most modern web applications and mobile backends
- Public APIs (Twitter, GitHub, Stripe, etc.)
- Microservices architectures
- Cloud provider APIs (AWS, Azure, Google Cloud)

**Key characteristics:**
- Stateless requests
- Resource-based URLs (e.g., /users/123)
- JSON responses (typically)
- Standard HTTP status codes (200, 201, 400, 404, 500)

**Example:**
GET /api/users/123
Response: {"id": 123, "name": "John", "email": "john@example.com"}

**Testing with SysOps:**
```powershell
# GET request
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -Method GET

# POST with body
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -Method POST -Body @{name="John"}

# With authentication
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -BearerToken "your-token"
```

---

### SOAP (Simple Object Access Protocol)

**What it is:**
An older protocol that uses XML for request/response formatting. More rigid and verbose than REST.

**Where you'll encounter it:**
- Enterprise legacy systems
- Financial services (some banks still use SOAP)
- Government agencies
- Older Microsoft products (SharePoint, Dynamics)
- Some telecommunication providers

**Key characteristics:**
- XML-based envelopes
- WSDL (Web Services Description Language) for documentation
- More complex than REST
- Built-in error handling (SOAP Faults)
- Can use various transport protocols (HTTP, SMTP, etc.)

**Example SOAP Envelope:**
```xml
<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetUser>
      <userId>123</userId>
    </GetUser>
  </soap:Body>
</soap:Envelope>
```

**Testing with SysOps:**
```powershell
# Simple SOAP request
.\Test-SoapEndpoint.ps1 -Url "https://service.example.com/soap" -Action "GetUser" -BodyParams @{userId=123}

# With authentication
.\Test-SoapEndpoint.ps1 -Url "https://service.example.com/soap" -Action "GetUser" -Username "admin" -Password "pass"
```

**Common gotchas:**
- SOAPAction header is required
- Namespace handling can be tricky
- Some services require specific WS-Security headers
- XML payload size can be large

---

### Microsoft Graph API

**What it is:**
Microsoft's unified API for accessing Microsoft 365 data and services.

**Where you'll encounter it:**
- Microsoft 365 administration
- Azure AD / Entra ID management
- SharePoint Online
- Teams management
- OneDrive integration
- Exchange Online

**Key characteristics:**
- OAuth2 client credentials flow (typically)
- Standard REST-like interface
- Returns JSON
- Requires Azure AD / Entra ID app registration
- Rate limiting is strict

**Example:**
GET https://graph.microsoft.com/v1.0/users
Authorization: Bearer eyJ0eXAi...
Response: {"value": [{"id": "...", "displayName": "John Doe", ...}]}

**Testing with SysOps:**
```powershell
# List users
.\Test-GraphEndpoint.ps1 -TenantId "your-tenant" -ClientId "your-client-id" -ClientSecret "your-secret" -Endpoint "/users"

# Using config
.\Test-GraphEndpoint.ps1 -UseConfig

# Batch test
.\Test-BatchRequests.ps1 -Type Graph
```

**Authentication:**
Requires Azure AD app registration with appropriate permissions. The scripts support:
- Client credentials flow (server-to-server)
- Pre-existing access tokens

---

### GraphQL

**What it is:**
A query language for APIs that allows clients to request exactly the data they need.

**Where you'll encounter it:**
- Modern web applications (especially React/Vue/Angular frontends)
- GitHub's API (v4)
- Shopify's API
- Contentful, Strapi, Prisma
- Many newer APIs

**Key characteristics:**
- Single endpoint for all operations
- Client specifies exactly what data to return
- Strongly typed schema
- Supports queries (read) and mutations (write)
- Real-time subscriptions

**Example Query:**
query {
  user(id: 123) {
    name
    email
    posts {
      title
    }
  }
}

**Example Mutation:**
mutation {
  createUser(name: "John", email: "john@example.com") {
    id
    name
  }
}

**Testing with SysOps:**
```powershell
# Simple query
.\Test-GraphQlEndpoint.ps1 -Url "https://api.example.com/graphql" -Query "{ users { id name } }"

# With variables
.\Test-GraphQlEndpoint.ps1 -Url "https://api.example.com/graphql" -Query "query GetUser($id: ID!) { user(id: $id) { name } }" -Variables @{id=123}

# GitHub API example
.\Test-GraphQlEndpoint.ps1 -Url "https://api.github.com/graphql" -Query "{ viewer { login } }" -BearerToken "your-github-token"
```

**Common gotchas:**
- Query syntax must be exact
- Variables are separate from query
- POST vs GET methods
- Rate limiting is per-query complexity, not just requests

---

## Legacy Scripts

The following scripts are kept for backward compatibility:

### Test-WebApplication.ps1

Test a single web application's availability (HTTP status check only).

```powershell
.\Test-WebApplication.ps1 -Url "https://www.example.com"
.\Test-WebApplication.ps1 -Url "https://intranet.company.com" -ExpectedStatusCode 200
.\Test-WebApplication.ps1 -Url "https://selfsigned.site.com" -IgnoreSSL
```

### Test-WebApplicationBatch.ps1

Test multiple web applications from config.

```powershell
.\Test-WebApplicationBatch.ps1 -UseConfig
.\Test-WebApplicationBatch.ps1 -Url "https://api.example.com/health"
```

---

## Scripts Reference

| Script | Purpose |
|--------|---------|
| Test-RestEndpoint.ps1 | Test REST/JSON APIs (GET, POST, PATCH, DELETE) |
| Test-SoapEndpoint.ps1 | Test SOAP XML web services |
| Test-GraphEndpoint.ps1 | Test Microsoft Graph API |
| Test-GraphQlEndpoint.ps1 | Test GraphQL endpoints |
| Test-BatchRequests.ps1 | Run multiple endpoint tests from config |
| Test-WebApplication.ps1 | Simple HTTP status check (legacy) |
| Test-WebApplicationBatch.ps1 | Batch HTTP status check (legacy) |

---

## Configuration

Edit Config/settings.json to add your endpoints. See the webTests section in settings.json for the full schema.

---

## Authentication Methods

### API Key
```powershell
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/data" -ApiKey "your-key" -ApiKeyHeader "X-API-Key"
```

### Bearer Token
```powershell
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/data" -BearerToken "your-jwt-token"
```

### Basic Auth
```powershell
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/data" -Username "user" -Password "pass"
```

### Microsoft Graph (OAuth2)
```powershell
.\Test-GraphEndpoint.ps1 -TenantId "xxx" -ClientId "xxx" -ClientSecret "xxx" -Endpoint "/users"
```

---

## Retry and Logging

```powershell
# Enable retry (disabled by default)
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -EnableRetry -RetryCount 3

# Console only logging
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -LogToConsoleOnly

# File only logging  
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -LogToFileOnly

# Skip SSL validation (for dev/test)
.\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -SkipSslValidation
```

---

## Environment Variables

Use environment variables in settings.json for sensitive data:
{
  "bearerToken": "${API_TOKEN}",
  "clientSecret": "${GRAPH_CLIENT_SECRET}"
}

Set environment variables:
```powershell
$env:API_TOKEN = "your-token-here"
```

---

## Common Use Cases

### Health Check Monitoring
```powershell
# Add to scheduled task for regular monitoring
.\Test-BatchRequests.ps1 -OutputPath "C:\Reports\health-$(Get-Date -Format 'yyyyMMdd').json"
```

### CI/CD Integration
```powershell
# Exit code 0 = success, non-zero = failure
$result = .\Test-RestEndpoint.ps1 -Url "https://api.example.com/health" -ExpectedStatusCode 200 -PassThru
if (-not $result.Success) { exit 1 }
```

### API Development
```powershell
# Quick test while developing
.\Test-RestEndpoint.ps1 -Url "http://localhost:3000/api/users" -Method POST -Body @{name="Test"} -PassThru
```
