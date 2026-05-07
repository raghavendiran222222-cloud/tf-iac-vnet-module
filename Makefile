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
	  printf 'module "spoke_vnet" {\n  source = "../../"\n}\n' > override.tf
	cd $(EXAMPLE_DIR) && terraform init -backend=false
	cd $(EXAMPLE_DIR) && terraform plan -backend=false \
	  -var "subscription_id=$$ARM_SUBSCRIPTION_ID"

# apply is intentionally absent — this is a module repo.
# Modules have no backend or state. Apply is run by consumers, not here.
# In CI, only 'plan' is executed. See ADR-005.

test:
	pytest tests/ -v --tb=short

docs:
	terraform-docs --config .terraform-docs.yml .

clean:
	find . -type d -name '.terraform' -prune -exec rm -rf {} +
	find . -name 'override.tf' -delete
	find . -name 'tfplan' -delete
	find . -name 'tfplan.json' -delete
	find . -name '*.tfplan' -delete
	find . -name 'checkov.sarif' -delete
	find . -name 'plan_output.txt' -delete
