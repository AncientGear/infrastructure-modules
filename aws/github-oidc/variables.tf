variable "tags" {
    description = "Tags assigned to the shared GitHub OIDC provider."
    type        = map(string)
    default     = {}
}