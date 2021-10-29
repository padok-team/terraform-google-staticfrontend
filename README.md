# Google Static Frontend Terraform module

Terraform module which creates storage buckets, iam binding and access control resources on Google Cloud Platform. 

## User Stories for this module

- AAFrontend I can be deployed and load balanced
- AMultipleFrontends we can be deployed and load balanced

## Usage

```hcl
module "frontend" {
  source   = "https://github.com/padok-team/terraform-google-staticfrontend"
  name     = "simplestaticfrontend"
  location = "europe-west1"
}
```

## Examples

- [Example of use case](examples/simple_frontend/main.tf)
- [Example of other use case](examples/multiple_frontends/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location to use for your service | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the service you're referring to | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | The feature flag to allow destroying bucket event if it contains files. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the service. | `map(string)` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The bucket's name |
<!-- END_TF_DOCS -->
