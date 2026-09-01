variable "bucket_name" {
  type = string

  validation {
    condition = length(regexall(
      "^(?![0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$)(?!.*\\.\\.)(?!.*\\.-)(?!.*-\\.)[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$",
      var.bucket_name
    )) > 0

    error_message = "Bucket name must follow AWS S3 naming rules: 3-63 chars, lowercase letters, numbers, dots, hyphens; no consecutive dots, no IP-style names, must start/end with alphanumeric."
  }
}


#               ^(?![0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$)
#               disallow IP address‑formatted names
#               
#               (?!.*\\.\\.)
#               disallow consecutive dots
#               
#               (?!.*\\.-)
#               disallow dot + hyphen
#               
#               (?!.*-\\.)
#               disallow hyphen + dot
#               
#               [a-z0-9] at start
#               must start with alphanumeric
#               
#               [a-z0-9]$ at end
#               must end with alphanumeric
#               
#               [a-z0-9.-]{1,61}
#               middle portion; combined with start/end gives 3–63 total characters