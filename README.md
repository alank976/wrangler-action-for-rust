# wrangler-action-for-rust

This is namely a github action which helps deploy Cloudflare workers via wrangler CLI. There is [an official action from Cloudflare](https://github.com/cloudflare/wrangler-action), however, it doesn't support Rust (via wasm-bindgen) for now as [this issue describes](https://github.com/cloudflare/wrangler-action/issues/16). 

## Example

### wrangler build

```yaml
name: Build on feature branch


on: pull_request

jobs: 
  build:
    runs-on: ubuntu-latest
    name: Build
    steps:
      - uses: actions/checkout@v2
      - name: Publish
        uses: alank976/wrangler-action-for-rust@1.0.0
        publish: false
        preCommands: wrangler build
```
### wrangler publish

```yaml
name: Deploy

on:
  push:
    branches:
      - master
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    name: Deploy
    steps:
      - uses: actions/checkout@v2
      - name: Publish
        uses: alank976/wrangler-action-for-rust@1.0.0
        with:
          apiToken: ${{ secrets.CF_API_TOKEN }}

```

## Approach
This action uses Rust as base image instead of node since Rust compiler is relatively larger so this way betters off the docker caching layer. This docker image basically is a Rust + Wrangler after all.

## Versioning
As mentioned, there are several versions have to be managed. We have Rust and wrangler. Only wrangler's can be specified via Action inputs and the rest of aforementioned are locked-in versions. 

## Github action interface
This action simply uses subset of [the official one](https://github.com/cloudflare/wrangler-action/blob/master/action.yml), but remove the legacy ones

## Inputs, Authentication, etc
Please refer to the [official one](https://github.com/cloudflare/wrangler-action) for details 
