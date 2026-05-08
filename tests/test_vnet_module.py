"""
Plan-only tests for the tf-iac-vnet-module using pytest + tftest.

Prerequisites:
    pip install pytest tftest==1.8.7

Required environment variables (real Azure credentials):
    ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_TENANT_ID
    (ARM_CLIENT_SECRET for SPN, or Azure CLI login)

Run:
    pytest tests/ -v
"""

import os
import pytest
import tftest

EXAMPLES_BASIC = os.path.join(os.path.dirname(__file__), "..", "examples", "basic")

APPROVED_LOCATIONS = {"eastus2", "centralus", "eastus", "westus2", "westeurope", "northeurope"}
REQUIRED_TAGS = {"Application", "Owner", "Environment", "CostCenter", "ManagedBy", "CreatedDate"}

_CRED_VARS = {"ARM_SUBSCRIPTION_ID", "ARM_CLIENT_ID", "ARM_TENANT_ID"}
_has_credentials = _CRED_VARS.issubset(os.environ)

requires_credentials = pytest.mark.skipif(
    not _has_credentials,
    reason=f"Set {_CRED_VARS} to run integration tests",
)


@pytest.fixture(scope="module")
def plan():
    if not _has_credentials:
        pytest.skip(f"Set {_CRED_VARS} to run integration tests")

    extra_vars = {"subscription_id": os.environ["ARM_SUBSCRIPTION_ID"]}

    tf = tftest.TerraformTest(EXAMPLES_BASIC)
    tf.setup(use_cache=False, extra_vars=extra_vars)
    return tf.plan(output=True)


@requires_credentials
def test_vnet_is_planned(plan):
    """AVM module must plan at least one azapi_resource representing the VNet."""
    vnet_resources = [
        k for k in plan.resource_changes
        if "azapi_resource" in k and "subnet" not in k.lower() and "peering" not in k.lower()
    ]
    assert len(vnet_resources) >= 1, (
        f"Expected at least one VNet resource, found: {list(plan.resource_changes.keys())}"
    )


@requires_credentials
def test_subnets_are_planned(plan):
    """Basic example must plan at least 2 subnets."""
    subnet_resources = [
        k for k in plan.resource_changes
        if "subnet" in k.lower() and "association" not in k.lower()
    ]
    assert len(subnet_resources) >= 2, (
        f"Expected >= 2 subnets, found {len(subnet_resources)}: {subnet_resources}"
    )


@requires_credentials
def test_no_hub_peering_in_basic(plan):
    """Basic example has no hub_vnet_id set — no peering resources should appear."""
    peering_resources = [
        k for k in plan.resource_changes
        if "peering" in k.lower()
    ]
    assert len(peering_resources) == 0, (
        f"Expected no peering resources in basic example, found: {peering_resources}"
    )


@requires_credentials
def test_required_tags_present(plan):
    """VNet resource must carry all required tags including auto-injected ones."""
    vnet_key = next(
        (k for k in plan.resource_changes
         if "azapi_resource" in k and "subnet" not in k.lower() and "peering" not in k.lower()),
        None,
    )
    assert vnet_key is not None, "No VNet resource found in plan"

    change = plan.resource_changes[vnet_key]
    planned_tags = change.get("change", {}).get("after", {}).get("tags", {}) or {}
    missing = REQUIRED_TAGS - set(planned_tags.keys())
    assert not missing, f"Missing required tags on VNet: {missing}. Found: {set(planned_tags.keys())}"


@requires_credentials
def test_telemetry_disabled(plan):
    """No telemetry resources should be planned (enable_telemetry=false)."""
    telemetry_resources = [
        k for k in plan.resource_changes
        if "telemetry" in k.lower()
    ]
    assert len(telemetry_resources) == 0, (
        f"Telemetry resources found — enable_telemetry should be false: {telemetry_resources}"
    )


@requires_credentials
def test_location_is_valid(plan):
    """VNet must be planned in an approved region."""
    vnet_key = next(
        (k for k in plan.resource_changes
         if "azapi_resource" in k and "subnet" not in k.lower() and "peering" not in k.lower()),
        None,
    )
    assert vnet_key is not None, "No VNet resource found in plan"

    change = plan.resource_changes[vnet_key]
    location = change.get("change", {}).get("after", {}).get("location", "")
    assert location in APPROVED_LOCATIONS, (
        f"VNet location '{location}' is not in approved list: {APPROVED_LOCATIONS}"
    )
