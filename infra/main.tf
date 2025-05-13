terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

#####################
# Secret Manager
#####################
data "google_secret_manager_secret_version" "openai" {
  secret  = var.openai_secret_name
  version = "latest"
}
data "google_secret_manager_secret_version" "taapi" {
  secret  = var.taapi_secret_name
  version = "latest"
}
data "google_secret_manager_secret_version" "alpaca_key" {
  secret  = var.alpaca_key_secret_name
  version = "latest"
}
data "google_secret_manager_secret_version" "alpaca_secret" {
  secret  = var.alpaca_secret_name
  version = "latest"
}

#####################
# Cloud Run Service
#####################
resource "google_cloud_run_service" "spy_trader" {
  name     = "spy-trader"
  location = var.region

  template {
    spec {
      containers {
        image = var.image
        env {
          name  = "OPENAI_API_KEY"
          value = data.google_secret_manager_secret_version.openai.secret_data
        }
        env {
          name  = "TAAPI_TOKEN"
          value = data.google_secret_manager_secret_version.taapi.secret_data
        }
        env {
          name  = "ALPACA_KEY_ID"
          value = data.google_secret_manager_secret_version.alpaca_key.secret_data
        }
        env {
          name  = "ALPACA_SECRET"
          value = data.google_secret_manager_secret_version.alpaca_secret.secret_data
        }
        env {
          name  = "GCP_PROJECT"
          value = var.project_id
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.spy_trader.location
  project  = var.project_id
  service  = google_cloud_run_service.spy_trader.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

#####################
# Scheduler Service Account
#####################
resource "google_service_account" "scheduler" {
  account_id   = "scheduler-agent"
  display_name = "Cloud Scheduler Service Account"
}

resource "google_cloud_run_service_iam_member" "scheduler_invoker" {
  location = google_cloud_run_service.spy_trader.location
  project  = var.project_id
  service  = google_cloud_run_service.spy_trader.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

#####################
# Cloud Scheduler Job
#####################
resource "google_cloud_scheduler_job" "run_trader" {
  name        = "spy-trader-schedule"
  description = "Trigger the SPY trader flow hourly"
  schedule    = "55 * * * *"
  time_zone   = var.time_zone

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_service.spy_trader.status[0].url}/run"
    oidc_token {
      service_account_email = google_service_account.scheduler.email
    }
    headers = {
      "Content-Type" = "application/json"
    }
    body = base64encode(jsonencode({}))
  }
}
