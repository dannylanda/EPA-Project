# AI Content Rewriter - Application Installation Guide

## Overview
This document provides a detailed step-by-step guide to installing and deploying the **AI Content Rewriter** plugin as part of a fully automated **WordPress deployment**. This deployment leverages **AWS CloudFormation**, **GitHub Actions**, and **automated scripts** to ensure a hands-off and secure installation.

---

## 1. **Deployment Flow Overview**

1. **CloudFormation Template Stored in S3**: 
   - The infrastructure definition is securely stored in an **AWS S3** bucket.
   
2. **CloudFormation Deployment**:
   - The CloudFormation stack is deployed, provisioning the necessary infrastructure including EC2 instances, security groups, IAM roles, and network configurations.
   - **AWS WAF rules** are set up by default to enhance application security.
   - **Amazon CloudWatch** is configured to monitor application performance and security logs.

3. **Manual Trigger for GitHub Actions**:
   - Once the infrastructure is deployed, a manual step is required to trigger **GitHub Actions**.

4. **GitHub Actions Execution**:
   - GitHub Actions retrieves sensitive information (e.g., API keys, database credentials) from **GitHub Secrets**.
   - The workflow runs scripts on the appropriate servers to configure and install the application.

5. **Automated Script Execution**:
   - Scripts are executed to pull in and install the AI Content Rewriter plugin.
   - **Security measures** such as **WAF rules**, **Amazon CloudWatch monitoring**, and **Chkrootkit scans** are applied automatically.

---

## 2. **Prerequisites**

### 2.1 **Infrastructure Requirements**
- **AWS Account** with permissions to deploy CloudFormation templates.
- **AWS S3 Bucket** to store the CloudFormation template.
- **AWS CloudFormation** service enabled.
- **EC2 Instances** with necessary security groups and IAM roles.
- **SSL Certificates** (using Let's Encrypt or a valid CA).
- **AWS WAF** (Web Application Firewall) configured by default.
- **Amazon CloudWatch** for monitoring and logging.

### 2.2 **Software Requirements**
- **Ubuntu 20.04+** (or any compatible Linux distribution).
- **Nginx** as the web server.
- **PHP 7.4+** with required extensions:
  - `php-fpm`, `php-cli`, `php-curl`, `php-mbstring`, `php-mysqli`, `php-xml`, `php-zip`, `php-gd`, `php-intl`.
- **MySQL** (or MariaDB) for the database.
- **AWS CLI** for managing cloud resources.
- **WP-CLI** for WordPress management.
- **Certbot** for SSL certificate management.
- **Chkrootkit** for malware and rootkit detection.
- **Amazon CloudWatch Logs Agent** for monitoring application logs.

---

## 4. **Post-Installation Tasks**
1. **Verify WordPress is running** by navigating to your domain.
2. **Test the AI Content Rewriter Plugin** by entering sample content.
3. **Check SSL Certificate** using:
   ```sh
   openssl s_client -connect yourdomain.com:443
   ```
4. **Monitor Security Logs** using **Amazon CloudWatch**.
   - Check logs for any security threats or performance issues.
5. **Review AWS WAF Logs** to ensure security rules are functioning as expected.
6. **Monitor Server Health** using CloudWatch metrics.

---

## 5. **Maintenance & Updates**
- Regularly update **WordPress Core, Plugins, and System Packages**.
- Monitor **AWS WAF** logs for any suspicious activity.
- Schedule **Chkrootkit scans** to run periodically.
- Back up **wp-config.php** and other critical files to **AWS S3**.
- Review **CloudWatch metrics and alerts** for proactive maintenance.

---

## Conclusion
This document outlines a fully automated **WordPress deployment** using **AWS CloudFormation, GitHub Actions, WP-CLI, and security enhancements**. With these steps, the **AI Content Rewriter** plugin is deployed securely and efficiently, minimising manual intervention while leveraging **AWS WAF and CloudWatch** for security and monitoring.
