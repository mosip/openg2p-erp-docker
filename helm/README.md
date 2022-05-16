## Installation on a Kubernetes Cluster

### Installation

-   ```
    kubectl create ns <NS>
    ```
- Configure `ingress` section in values.yaml file if required.
    - Else if `istio-ingressgateway` is being used, run the following:
        ```
        ./apply-istio-ingress.sh <NS> <hostname>
        ```
- Then add bitnami helm repo and install the chart. (Do NOT change the chart version in the following command. The installation is configured to only work with bitnami chart version 19.0.13)
    ```
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update bitnami
    helm install openg2p-erp -n <NS> --version 19.0.13 -f values.yaml
    ```
- Once the installation finishes (initial installation will take sometime), Login in to ERP at the specified hostname. Required Modules should already be installed.
- Upon initial login, navigate to "Beneficiaries" app. Then click on "Configuration" -> "Identifications". Create new Identification with:
  - ID Name: `Tax ID`
  - Code: `taxid`

### Notes

- If using tls, configure a reverse proxy to redirect http traffic to https, because occasionally odoo is redirecting requests to http. Ignore if not applicable.
- If persistence is off, every pod restart will pull in latest code and reinitialize database.
  - It is not suggested to switch off persistence, as this could cause other app failures.
- If persistence is on:
  - To apply any config changes in helm values.yaml, run the following (This will NOT update/reinitialize the database with the latest changes).
    ```
    helm upgrade openg2p-erp -n <NS> --version 19.0.13 -f updated-values.yaml
    ```
  - To pull in latest code of the current branch from github, run the following on the erp pods (This will NOT update/reinitialize the database with the latest changes).
    - ```
        kubectl exec -it <erp-deployment-pod-name> -n <NS> -- rm /bitnami/odoo/.user_scripts_initialized
        ```
    - then delete the pod to restart it.
  - To upgrade/reinitialize any particular module in database; Login as admin. Navigate to Apps menu. Remove the "Apps" filter, and upgrade the module.
