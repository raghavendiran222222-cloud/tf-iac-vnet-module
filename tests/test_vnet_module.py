"""
tests/test_vnet_module.py

Automated pytest/tftest tests for tf-iac-vnet-module (AVM-backed).
Runs terraform plan against examples/basic and validates the plan output.

Run:
    pytest tests/ -v

Requirements:
    pip install pytest tftest
    ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
"""

import pytest
import tftest

EXAMPLE_DIR = "examples/basic"


@pytest.fixture(scope="module")
def plan():
    tf = tftest.TerraformTest(EXAMPLE_DIR, basedir=None)
    tf.setup()
    yield tf.plan(output=True)
    tf.teardown()


def test_avm_vnet_module_is_planned(plan):
    """AVM VNet module call must appear in the plan."""
    module_keys = list(plan.modules.keys()) if hasattr(plan, "modules") else []
    resource_keys = list(plan.resources.keys())
    vnet_resources = [k for k in resource_keys if "virtual_network" in k.lower()]
    assert len(vnet_resources) >= 1, (
        f"Expected at least 1 virtual_network resource, found: {vnet_resources}"
    )


def test_subnets_are_planned(plan):
    """Both subnets from the basic example must appear in the plan."""
    resource_keys = list(plan.resources.keys())
    subnet_resources = [k for k in resource_keys if "subnet" in k.lower()
                        and "association" not in k.lower()]
    assert len(subnet_resources) >= 2, (
        f"Expected >= 2 subnet resources, found: {subnet_resources}"
    )


def test_no_hub_peering_in_basic_example(plan):
    """Hub peering must NOT be planned when hub_vnet_id is not set."""
    resource_keys = list(plan.resources.keys())
    peering_resources = [k for k in resource_keys
                         if "virtual_network_peering" in k.lower()]
    assert len(peering_resources) == 0, (
        f"Expected no peerings in basic example, found: {peering_resources}"
    )


def test_required_tags_present(plan):
    """All BDT-MSD required tags (FDD Table 12) must be present on the VNet."""
    required_tags = [
        "Application", "DevOwner", "BusinessOwner", "Environment",
        "DataClassification", "BusinessCriticality", "IACRepository", "CreationDate",
    ]
    resource_keys = list(plan.resources.keys())
    vnet_key = next(
        (k for k in resource_keys if "virtual_network" in k.lower()
         and "peering" not in k.lower() and "subnet" not in k.lower()),
        None
    )
    assert vnet_key is not None, "No VNet resource found in plan"
    tags = plan.resources[vnet_key]["values"].get("tags", {})
    missing = [t for t in required_tags if t not in tags]
    assert not missing, f"Missing required BDT-MSD tags: {missing}"


def test_location_is_approved(plan):
    """VNet location must be one of the BDT-MSD approved regions (FDD §1.3 A2)."""
    approved = {"eastus2", "centralus", "eastus"}
    resource_keys = list(plan.resources.keys())
    vnet_key = next(
        (k for k in resource_keys if "virtual_network" in k.lower()
         and "peering" not in k.lower() and "subnet" not in k.lower()),
        None
    )
    assert vnet_key is not None, "No VNet resource found in plan"
    location = plan.resources[vnet_key]["values"].get("location", "")
    assert location in approved, (
        f"VNet location '{location}' is not in approved BDT-MSD regions: {approved}"
    )


def test_telemetry_disabled(plan):
    """AVM telemetry resource must not appear in plan (enable_telemetry=false)."""
    resource_keys = list(plan.resources.keys())
    telemetry_resources = [k for k in resource_keys if "telemetry" in k.lower()]
    assert len(telemetry_resources) == 0, (
        f"Telemetry resources found in plan (expected none): {telemetry_resources}"
    )
