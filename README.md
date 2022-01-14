# Google Static Frontend Terraform module

Terraform module which creates storage buckets, iam binding and access control resources on Google Cloud Platform.

## User Stories for this module

- AAFrontend I can be deployed and load balanced
- AMultipleFrontends we can be deployed and load balanced

## Usage

```hcl
module "frontend" {
  source   = "git@github.com:padok-team/terraform-google-staticfrontend.git?ref=v1.0.0"
  name     = "simplestaticfrontend"
  location = "europe-west1"
}

module "loadbalancer" {
  source = "git@github.com:padok-team/terraform-google-lb.git"

  name = "demo-frontend-padok-fr"
  buckets_backends = {
    frontend = {
      hosts = ["demo.frontend.padok.fr"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = module.frontend.bucket.name
    }
  }
  service_backends = {}
  ssl_certificates = []
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
| <a name="input_location"></a> [location](#input\_location) | The location to use for your service. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the service you're referring to. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | The feature flag to allow destroying bucket event if it contains files. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the service. | `map(string)` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The bucket. |
<!-- END_TF_DOCS -->

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
