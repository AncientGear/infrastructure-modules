variable "env" {
  description = "Environment name."
  type        = string
}

variable "eks_version" {
  description = "Desired Kubernetes master version."
  type        = string
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones."
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public Amazon EKS API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes."
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  description = "EKS node groups"
  type        = map(any)
}

variable "coredns" {
  description = "Optional management of the EKS CoreDNS add-on. Disabled by default."
  type = object({
    enabled                   = optional(bool, false)
    addon_version             = optional(string)
    corefile                  = optional(string)
    replica_count             = optional(number, 2)
    workload_toleration_value = optional(string)
  })
  default = {}

  validation {
    condition = !var.coredns.enabled || (
      (var.coredns.addon_version == null ? true : length(trimspace(var.coredns.addon_version)) > 0) &&
      (var.coredns.workload_toleration_value == null ? true : length(trimspace(var.coredns.workload_toleration_value)) > 0)
    )
    error_message = "When CoreDNS is enabled, provided addon_version and workload_toleration_value must not be empty."
  }

  validation {
    condition     = var.coredns.replica_count > 0 && var.coredns.replica_count == floor(var.coredns.replica_count)
    error_message = "CoreDNS replica_count must be a positive integer."
  }
}

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}