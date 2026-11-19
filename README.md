# FormFlow ⚡

A lightweight web application designed to demonstrate a complete delivery pipeline from Terraform-provisioned cloud infrastructure to automated GitHub Actions deployment.

## What It Does

- **One form**: Visitors enter their name, email, and message.
- **One destination**: Submissions are saved to a persistent SQLite database.
- **One place to see submissions**: A simple page lists all saved submissions in real-time.

---

## Architecture Overview

```
                        [ Developer pushes to main ]
                                     │
                                     ▼
                        [ GitHub Actions Pipeline ]
                                     │
                 Reads DEPLOY_HOST   │   SSH + Docker Compose
                 (from Terraform)    │
                                     ▼
                ┌────────────────────────────────────────┐
                │             Azure Linux VM             │
                │                                        │
                │   ┌────────────────────────────────┐   │
                │   │         Docker Compose         │   │
                │   │                                │   │
                │   │    FormFlow Container (:80)    │   │
                │   │    ├── Express HTTP Server     │   │
                │   │    ├── / (Form Page)           │   │
                │   │    ├── /submissions (List)     │   │
                │   │    └── SQLite (Persistent Vol) │   │
                │   └────────────────────────────────┘   │
                └────────────────────────────────────────┘
```

---

## Project Structure

```
FormFlow/
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD deployment pipeline
├── application/
│   ├── public/
│   │   ├── index.html              # The submission form
│   │   ├── submissions.html        # Page listing submissions
│   │   └── styles.css              # Minimal clean styling
│   ├── server.js                   # Lightweight Express + SQLite backend
│   ├── package.json
│   ├── Dockerfile                  # Container definition (node:22-alpine)
│   └── docker-compose.yml          # Service definition mapped to port 80
├── terraform-infrastructure/
│   ├── provider.tf                 # AzureRM and GitHub providers
│   ├── main.tf                     # Azure VM, Networking, NSG, and GitHub secret
│   ├── variables.tf                # Configuration variables
│   ├── output.tf                   # Public IP and SSH connection strings
│   └── terraform.tfvars.example    # Variable templates
└── .gitignore                      # Protects secrets, tfstate, and credentials
```

---

## Running Locally

To run the application locally without Docker:

```bash
cd application
npm install
npm start
```
Visit `http://localhost:3000` to view the form and `http://localhost:3000/submissions` to view submissions.

### Running with Docker Compose locally:

```bash
cd application
docker compose up -d --build
```
Visit `http://localhost:80` (or `http://localhost`).

---

## Deploying Infrastructure

1. Log into Azure and export your GitHub token:
   ```bash
   az login
   export GITHUB_TOKEN="ghp_yourPersonalAccessToken"
   ```

2. Copy the example variables and provide your values:
   ```bash
   cp terraform-infrastructure/terraform.tfvars.example terraform-infrastructure/terraform.tfvars
   ```

3. Initialize and apply Terraform:
   ```bash
   cd terraform-infrastructure
   terraform init
   terraform apply
   ```

Terraform automatically provisions the Azure VM and injects the new public IP into the `DEPLOY_HOST` GitHub Actions secret in your repository.
