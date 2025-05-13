variable "project_id" {
  description = "GCP project to deploy into"
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run and Scheduler"
  type        = string
  default     = "us-central1"
}

variable "time_zone" {
  description = "Time zone for Scheduler cron"
  type        = string
  default     = "America/Chicago"
}

variable "image" {
  description = "Container image URI (e.g. gcr.io/PROJECT_ID/spy-agent-trader:latest)"
  type        = string
}

variable "openai_secret_name" {
  description = "Secret Manager secret name for the OpenAI API key"
  type        = string
}

variable "taapi_secret_name" {
  description = "Secret Manager secret name for the TAAPI token"
  type        = string
}

variable "alpaca_key_secret_name" {
  description = "Secret Manager secret name for the Alpaca Key ID"
  type        = string
}

variable "alpaca_secret_name" {
  description = "Secret Manager secret name for the Alpaca Secret Key"
  type        = string
}
