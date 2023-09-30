# My Helm Charts

Unofficial repository of helm charts created by me or forked and changed by me.

Warning Forked charts here contain changes from the original.

## Charts written by me

    - [capi-cluster](https://github.com/janip81/helm-charts/tree/main/charts/capi-cluster)

## Forked and modified charts made by other

    - [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)

## Adding this helm repository

To add the helm repository, run the following commands:

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo janip81
```

`values.yaml` files for the charts can be found in the `charts/[chartname]` directories.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
<alias>` to see the charts.

To install the <chart-name> chart:

    helm install my-<chart-name> <alias>/<chart-name>

To uninstall the chart:

    helm delete my-<chart-name>