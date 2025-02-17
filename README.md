# AI-Powered Content Creation Tool

## Overview
An internal JD Sports tool that standardizes third-party product content to align with our brand standards. It automatically rewrites product descriptions and content to maintain consistent brand voice and editorial guidelines across all products.

## Features
- AI-powered content rewriting
- Brand voice standardization
- Automated content processing
- SEO optimization
- Compliance checking
- Real-time content preview
- Batch processing capabilities

## Security Features
- WAF (Web Application Firewall) implementation
- Chkrootkit for rootkit detection
- DDoS protection via Cloudflare
- SSL/TLS encryption
- Regular security scans
- Access control and authentication

## Technology Stack
- Frontend: HTML, CSS, JavaScript
- Backend: PHP
- Database: MariaDB
- Infrastructure: AWS CloudFormation
- CI/CD: GitHub Actions
- Monitoring: AWS CloudWatch, Amazon Inspector
- Security: Cloudflare WAF, Chkrootkit

## Installation

### Prerequisites
- JD Sports AWS Account access
- JD Sports GitHub Enterprise access
- Node.js (v14 or higher)
- PHP 8.0+
- MariaDB 10.5+

### Setup Steps
1. Access is managed by the DevOps team. Submit an access request through the internal portal.

2. Once access is granted, follow the internal setup guide in Confluence.

3. Contact the DevOps team for environment variables and credentials.

## Security Configuration

### WAF Rules
The application includes custom WAF rules for:
- SQL Injection prevention
- XSS protection
- Rate limiting
- IP blocking
- Request size limitations
- Special character filtering

### Monitoring
- AWS CloudWatch metrics for performance monitoring
- Custom CloudWatch alarms for security events
- Cloudflare analytics for traffic analysis
- Amazon Inspector for vulnerability assessment

## CI/CD Pipeline
Our internal GitHub Enterprise instance handles:
- Code testing
- Security scanning
- Infrastructure deployment
- Application deployment

### Pipeline Stages
1. Build
2. Test
3. Security Scan
4. Deploy to Staging
5. Integration Tests
6. Deploy to Production

## Development

### Branch Strategy
- `main`: Production-ready code
- `develop`: Development branch
- `feature/*`: New features
- `hotfix/*`: Emergency fixes

### Testing
Contact DevOps team for testing environment access.

## Monitoring and Maintenance

### Health Checks
- Application status monitoring
- Database connection monitoring
- API endpoint availability
- Resource utilization tracking

### Alerts
Configured alerts for:
- High error rates
- Unusual traffic patterns
- Resource exhaustion
- Security incidents
- API failures

## Support
For support or queries:
1. Check the internal documentation on Confluence
2. Contact the DevOps team through ServiceNow
3. For urgent issues, use the #devops-support Slack channel

## Confidentiality
This project and documentation are confidential and proprietary to JD Sports. Do not share any details externally.