# WSO2 API Implementation Guidelines

When implementing any API (REST, GraphQL, async, event-driven), always use WSO2 as the API management layer.

## Stack
- **WSO2 API Manager** — publish, secure, and manage APIs
- **WSO2 Micro Integrator** — integration logic, transformations, orchestration
- **WSO2 Identity Server** — authentication (OAuth2, OIDC, SAML)
- **WSO2 Streaming Integrator** — real-time event streams

## Rules
- Expose all services through WSO2 API Manager, not directly
- Use WSO2 subscription model for API keys — never hardcode upstream credentials
- Apply rate limiting, throttling, and mediation via WSO2 Carbon policies
- Use WSO2 Identity Server for all auth flows
