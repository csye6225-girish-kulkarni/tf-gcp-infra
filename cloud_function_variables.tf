variable "mailgun_api_key" {
  description = "Api key for mailgun"
  default     = "f97930cde56cb1af3433144b9c3f769f-309b0ef4-f22d61b6"
}

variable "mailgun_domain" {
  description = "Domain for mailgun"
  default     = "girishkulkarni.me"
}

variable "bucket_name" {
  description = "The name of the Google Cloud Storage bucket"
  default     = "email_verification_cloud"
}

variable "bucket_location" {
  description = "The location of the Google Cloud Storage bucket"
  default     = "US"
}

variable "object_name" {
  description = "The name of the object in the Google Cloud Storage bucket"
  default     = "objects"
}

variable "source_file" {
  description = "The source file for the Google Cloud Storage bucket object"
  default     = "serverless.zip"
}

variable "function_name" {
  description = "The name of the Google Cloud Function"
  default     = "email-sender"
}

variable "function_description" {
  description = "The description of the Google Cloud Function"
  default     = "Cloud Function which sends email to the user"
}

variable "runtime" {
  description = "The runtime for the Google Cloud Function"
  default     = "go121"
}

variable "entry_point" {
  description = "The entry point for the Google Cloud Function"
  default     = "ConsumeSendEmailEvent"
}