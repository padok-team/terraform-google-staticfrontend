# CLOUD_PROVIDER TYPE Terraform module

Terraform module which creates **TYPE** resources on **CLOUD_PROVIDER**. This module is an abstraction of the [MODULE_NAME](https://github.com/a_great_module) by [@someoneverysmart](https://github.com/someoneverysmart).

## User Stories for this module

- AATYPE I can be highly available or single zone
- ...

## Usage

```hcl
module "example" {
  source = "https://github.com/padok-team/terraform-aws-example"

  example_of_required_variable = "hello_world"
}
```

## Examples

- [Example of use case](examples/example_of_use_case/main.tf)
- [Example of other use case](examples/example_of_other_use_case/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_example_of_required_variable"></a> [example\_of\_required\_variable](#input\_example\_of\_required\_variable) | Short description of the variable | `string` | n/a | yes |
| <a name="input_example_with_validation"></a> [example\_with\_validation](#input\_example\_with\_validation) | Short description of the variable | `list(string)` | n/a | yes |
| <a name="input_example_of_variable_with_default_value"></a> [example\_of\_variable\_with\_default\_value](#input\_example\_of\_variable\_with\_default\_value) | Short description of the variable | `string` | `"default_value"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example"></a> [example](#output\_example) | A meaningful description |
<!-- END_TF_DOCS -->
