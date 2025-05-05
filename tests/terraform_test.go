package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformBootstrap(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        VarFiles:     []string{"terraform.tfvars.example"}, // Use example vars for defaults
        Vars: map[string]interface{}{
            "resource_group_name":  "rg-test-" + random.UniqueId(),
            "location":             "westeurope",
            "storage_account_name": "tfstore" + random.UniqueId(),
            "container_name":       "tfstate",
        },
    }

    // Clean up resources after test
    defer terraform.Destroy(t, terraformOptions)

    // Initialize and apply Terraform
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
    containerName := terraform.Output(t, terraformOptions, "container_name")
    resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
    subscriptionID := terraform.Output(t, terraformOptions, "subscription_id")

    assert.NotEmpty(t, storageAccountName, "Storage account name should not be empty")
    assert.Equal(t, "tfstate", containerName, "Container name should be 'tfstate'")
    assert.NotEmpty(t, resourceGroupName, "Resource group name should not be empty")
    assert.NotEmpty(t, subscriptionID, "Subscription ID should not be empty")
}
