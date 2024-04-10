variable "security_location" {
  description = "The location for the Key Ring"
  default     = "us-east1"
}

variable "rotation_period" {
  description = "The rotation period for the Crypto Key"
  default     = "2592000s" # 30 days in seconds
}

variable "purpose" {
  description = "The purpose for the Crypto Key"
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_role" {
  description = "The role for the IAM Binding"
  default     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

variable "secret_id" {
  description = "The secret id for the Secret Manager Secret"
  default     = "vm-crypto-key-secret"
}