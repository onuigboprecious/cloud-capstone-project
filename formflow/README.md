# FormFlow ⚡

A lightweight web application designed to demonstrate a complete delivery pipeline from Terraform-provisioned cloud infrastructure to automated GitHub Actions deployment.

## What It Does

- **One form**: Visitors enter their name, email, and message.
- **One destination**: Submissions are saved to a PostgreSQL database.
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
                │   │    └── PostgreSQL DB           │   │
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
│   ├── backend/
│   │   ├── server.js               # Node.js + Express API + SQLite database
│   │   ├── package.json
│   │   └── Dockerfile              # Backend container (node:22-alpine)
│   ├── frontend/
│   │   ├── index.html              # The submission form
│   │   ├── submissions.html        # Page listing submissions
│   │   ├── styles.css              # Styling
│   │   ├── nginx.conf              # Nginx reverse proxy configuration
│   │   └── Dockerfile              # Frontend container (nginx:alpine)
│   └── docker-compose.yml          # Multi-container orchestration (ports 80:80)
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

### 1. Running with Docker Compose (Recommended)
This runs the `frontend` (Nginx on port 80) and `backend` (Node.js API + PostgreSQL) together:

```bash
cd formflow/application
docker compose up -d --build
```
Once started, visit:
- Form: `http://localhost/`
- Submissions: `http://localhost/submissions`
- Health check (backend): `http://localhost:5000/health`

---

### 2. Running Manually Without Docker

Because the application is separated into `backend` and `frontend`, navigate into `application/backend` for Node:

**Start the Backend:**
```bash
cd formflow/application/backend
npm install
npm start
```
The backend will start on **`http://localhost:5000`**. Open that link (or the frontend on port 80) in your browser to view the form and submit messages.

---

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
