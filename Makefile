EXAMPLE_DIR := examples/basic

.PHONY: bootstrap fmt lint validate plan test docs clean

bootstrap:
	pre-commit install
	terraform init -backend=false

fmt:
	terraform fmt -recursive .

lint:
	pre-commit run --all-files

validate:
	terraform init -backend=false
	terraform validate

plan:
	@cd $(EXAMPLE_DIR) && \
	  cat > override.tf << 'EOF'\
	module "spoke_vnet" { source = "../../" }\
	EOF
	cd $(EXAMPLE_DIR) && terraform init -backend=false
	cd $(EXAMPLE_DIR) && terraform plan -backend=false \
	  -var "subscription_id=$$ARM_SUBSCRIPTION_ID"

test:
	pytest tests/ -v --tb=short

docs:
	terraform-docs --config .terraform-docs.yml .

clean:
	find . -type d -name '.terraform' -prune -exec rm -rf {} +
	find . -name 'override.tf' -delete
