# capi-cluster helm-chart
Helm-chart for deploying cluster api workload clusters
Work In Progress! Use at own risk. NOT FINISHED!
Warning Forked charts here contain changes from the original.

## Adding this helm repository

To add the helm repository for the vSphere CSI driver, run the following commands:

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo capi-cluster
```

`values.yaml` files for the charts can be found in the `charts/[chartname]` directories.

## UsageTL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install my-cluster-name janip81/capi-cluster -f YOU-OWN-VALUES.yaml
```

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
<alias>` to see the charts.

To install the <chart-name> chart:

    helm install my-<chart-name> <alias>/<chart-name>

To uninstall the chart:

    helm delete my-<chart-name>

## Prerequisites

- [Kubernetes](https://kubernetes.io/)
- [Helm 3.1.0](https://helm.sh)
- [ClusterAPI](https://cluster-api.sigs.k8s.io/)