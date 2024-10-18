package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformPlanMultipleFrontends(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/multiple_frontends",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)
}
