package test

import (
	"crypto/tls"
	"fmt"
	"io"
	"strings"
	"sync"
	"testing"
	"text/template"
	"time"

	"github.com/gruntwork-io/terratest/modules/gcp"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

func TestMultipleFrontend(t *testing.T) {
	t.Parallel()

	// To skip step, uncomment corresponding lines
	// os.Setenv("SKIP_destroy", "true")
	// os.Setenv("SKIP_build", "true")
	// os.Setenv("SKIP_validate", "true")

	// The folder where we have our Terraform code
	workingDir := "../examples/multiple_frontends"

	// destroy all resources at the end
	defer test_structure.RunTestStage(t, "destroy", func() {
		// Load the Terraform Options saved by the earlier 'build' stage
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "build", func() {
		uniqueId := random.UniqueId()

		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: workingDir,
			Vars: map[string]interface{}{
				"namespace": strings.ToLower(uniqueId),
			},
		})

		// Save the Terraform Options struct so future test stages can use it
		test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

		// Apply
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		// Load the Terraform Options saved by the earlier 'build' stage
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

		bucketNames, err := terraform.OutputListE(t, terraformOptions, "bucket_names")
		require.NoError(t, err, "bucket_name cannot be output")

		domainNames, err := terraform.OutputListE(t, terraformOptions, "domain_names")
		require.NoError(t, err, "domain_name cannot be output")

		var wg sync.WaitGroup

		for k, bucketName := range bucketNames {
			wg.Add(1)

			bucketName := bucketName
			domainName := domainNames[k]

			go func() {
				defer wg.Done()
				// run effective test on bucket/domain
				runValidate(t, bucketName, domainName)
			}()
		}

		// wait for all tests to finish
		wg.Wait()
	})
}

func TestSimpleFrontend(t *testing.T) {
	t.Parallel()

	// To skip step, uncomment corresponding lines
	// os.Setenv("SKIP_destroy", "true")
	// os.Setenv("SKIP_build", "true")
	// os.Setenv("SKIP_validate", "true")

	// The folder where we have our Terraform code
	workingDir := "../examples/simple_frontend"

	// destroy all resources at the end
	defer test_structure.RunTestStage(t, "destroy", func() {
		// Load the Terraform Options saved by the earlier 'build' stage
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "build", func() {
		uniqueId := random.UniqueId()

		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: workingDir,
			Vars: map[string]interface{}{
				"namespace": strings.ToLower(uniqueId),
			},
		})

		// Save the Terraform Options struct so future test stages can use it
		test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

		// Apply
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		// Load the Terraform Options saved by the earlier 'build' stage
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

		bucketName, err := terraform.OutputE(t, terraformOptions, "bucket_name")
		require.NoError(t, err, "bucket_name cannot be output")

		domainName, err := terraform.OutputE(t, terraformOptions, "domain_name")
		require.NoError(t, err, "domain_name cannot be output")

		// run effective test on bucket/domain
		runValidate(t, bucketName, domainName)
	})
}

func runValidate(t *testing.T, bucketName, domainName string) {
	// check bucket exists
	err := gcp.AssertStorageBucketExistsE(t, bucketName)
	require.NoErrorf(t, err, "bucket '%s' does not exists", bucketName)

	// upload default index file
	index := `
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <title>Sample test</title>
</head>
<body>
  Sample test {{.BucketName}}
</body>
</html>`

	rd, wr := io.Pipe()

	go func() {
		// close writer to clean pipe
		defer wr.Close()

		// execute template on index
		tpl := template.Must(template.New("index").Parse(index))
		tpl.Execute(wr, struct {
			BucketName string
		}{BucketName: bucketName})
	}()

	url, err := gcp.WriteBucketObjectE(t, bucketName, "index.html", rd, "text/html")
	require.NoErrorf(t, err, "cannot upload index.html to bucket '%s'", bucketName)

	// defer empty storage bucket (for deletion)
	defer gcp.EmptyStorageBucket(t, bucketName)

	// test public access on bucket
	_, content, err := http_helper.HttpGetE(t, url, &tls.Config{})
	require.NoError(t, err, "cannot read '%s'", url)

	// test public access on lb
	lbURL := fmt.Sprintf("https://%s", domainName)
	err = http_helper.HttpGetWithRetryE(t, lbURL, &tls.Config{
		InsecureSkipVerify: true,
	}, 200, content, 20, time.Minute)
	require.NoError(t, err, "cannot read '%s'", lbURL)
}
