# Makefile for AWS CloudFront + S3 CDN Terraform Module

.PHONY: help init plan apply destroy validate fmt lint test clean docs

# Default target
help:
	@echo "AWS CloudFront + S3 CDN Terraform Module"
	@echo "========================================"
	@echo ""
	@echo "Available targets:"
	@echo "  help     - Show this help message"
	@echo "  init     - Initialize Terraform"
	@echo "  plan     - Plan Terraform changes"
	@echo "  apply    - Apply Terraform changes"
	@echo "  destroy  - Destroy Terraform resources"
	@echo "  validate - Validate Terraform configuration"
	@echo "  fmt      - Format Terraform code"
	@echo "  lint     - Lint Terraform code"
	@echo "  test     - Run tests"
	@echo "  clean    - Clean up temporary files"
	@echo "  docs     - Generate documentation"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Plan Terraform changes
plan:
	@echo "Planning Terraform changes..."
	terraform plan

# Apply Terraform changes
apply:
	@echo "Applying Terraform changes..."
	terraform apply

# Destroy Terraform resources
destroy:
	@echo "Destroying Terraform resources..."
	terraform destroy

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@echo "Linting Terraform code..."
	@if command -v tflint >/dev/null 2>&1; then \
		tflint; \
	else \
		echo "tflint not found. Install it from https://github.com/terraform-linters/tflint"; \
		exit 1; \
	fi

# Run tests (requires terratest)
test:
	@echo "Running tests..."
	@if command -v go >/dev/null 2>&1; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "Go not found. Install it to run tests."; \
		exit 1; \
	fi

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup
	rm -f *.tfplan

# Generate documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp && \
		mv README.md.tmp README.md; \
	else \
		echo "terraform-docs not found. Install it from https://terraform-docs.io/"; \
		exit 1; \
	fi

# Example-specific targets
example-basic:
	@echo "Running basic example..."
	cd examples/basic && terraform init && terraform plan

example-advanced:
	@echo "Running advanced example..."
	cd examples/advanced && terraform init && terraform plan

example-website:
	@echo "Running website example..."
	cd examples/website && terraform init && terraform plan

# Security scan (requires terrascan)
security-scan:
	@echo "Running security scan..."
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan -i terraform; \
	else \
		echo "terrascan not found. Install it from https://github.com/tenable/terrascan"; \
		exit 1; \
	fi

# Cost estimation (requires infracost)
cost-estimate:
	@echo "Estimating costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost not found. Install it from https://www.infracost.io/"; \
		exit 1; \
	fi

# Pre-commit checks
pre-commit: fmt validate lint
	@echo "Pre-commit checks completed successfully!"

# Full workflow
workflow: init validate fmt lint plan
	@echo "Full workflow completed successfully!"

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install terraform tflint terrascan infracost; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y terraform; \
		echo "Please install tflint, terrascan, and infracost manually"; \
	else \
		echo "Please install required tools manually:"; \
		echo "- Terraform: https://www.terraform.io/downloads.html"; \
		echo "- tflint: https://github.com/terraform-linters/tflint"; \
		echo "- terrascan: https://github.com/tenable/terrascan"; \
		echo "- infracost: https://www.infracost.io/"; \
	fi 