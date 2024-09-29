## FluxCD to set up base workloads in k8s (https://fluxcd.io/)
FluxCD is a Continuous Delivery (CD) and GitOps tool for Kubernetes. Flux is a Kubernetes-based application deployment and management solution

### Bootstrap Flux to a Kubernetes cluster
1. Export your credentials
```
export GITHUB_TOKEN=<your-token>
```

2. Check your Kubernetes cluster
```
flux check --pre
```

3. Install Flux onto your cluster
```
# Run the bootstrap command:
flux bootstrap github \
  --token-auth \
  --owner=gimhanem@gmail.com \
  --repository=wireapps=ta-gcp-infrastructure-tf \
  --branch=main \
  --path=clusters/nonprod \
  --personal
```

4. Check flux events
```
flux events -w
```

### Variables Reference

* **`gcp_ingress_loadbalancerip`**: Nginx ingress static LB IP
* **`cert_manager_service_account`**: certmanager gcp service account from the terrafrom output.
* **`cloudDNS_project_id`**: GCP cloud DNS project ID