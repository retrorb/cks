# Allowed resources

## **Kubernetes Documentation:**

<https://kubernetes.io/docs/> and their subdomains

<https://kubernetes.io/blog/> and their subdomains

<https://helm.sh/> and their subdomains

This includes all available language translations of these pages (e.g. <https://kubernetes.io/zh/docs/>)

- run ``time_left`` on work pc to **check time**
- run ``check_result`` on work pc to **check result**

## Questions

|        **1**        | **Create a Deployment**                                                                                                                                                                                                         |
| :-----------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|     Task weight     | 4%                                                                                                                                                                                                                              |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                 |
| Acceptance criteria | - Create namespace `deploy-ns`<br/>- Deployment: name=`web-app` ns=`deploy-ns` image=`nginx:alpine` replicas=`3` labels: `app=web-app`<br/>- Resource requests: cpu=`50m` memory=`64Mi` |
---
|        **2**        | **Scale an existing Deployment**                                                                                                                                    |
| :-----------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|     Task weight     | 2%                                                                                                                                                                  |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                     |
| Acceptance criteria | Deployment `scale-app` already exists in namespace `scale-ns` with `1` replica.<br/>Scale it to `4` replicas. |
---
|        **3**        | **Update a Deployment image**                                                                                                                                                              |
| :-----------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 4%                                                                                                                                                                                         |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                            |
| Acceptance criteria | Deployment `update-app` already exists in namespace `update-ns` with image `nginx:1.24`.<br/>Update the container image to `nginx:alpine`. Pods must be running after the update. |
---
|        **4**        | **Rollback a Deployment**                                                                                                                                                                                                           |
| :-----------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 6%                                                                                                                                                                                                                                  |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                     |
| Acceptance criteria | Deployment `rollback-app` in namespace `rollback-ns` was updated with a bad image and pods are failing.<br/>- Rollback the deployment to the previous working revision<br/>- Must have `2` ready replicas with image `nginx:alpine` |
---
|        **5**        | **Configure a rolling update strategy**                                                                                                                                                                     |
| :-----------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 4%                                                                                                                                                                                                          |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                             |
| Acceptance criteria | Deployment `strategy-app` already exists in namespace `strategy-ns`.<br/>Configure the rolling update strategy:<br/>- type: `RollingUpdate`<br/>- maxSurge: `1`<br/>- maxUnavailable: `0` |
---
|        **6**        | **Fix a broken Deployment**                                                                                                                                                |
| :-----------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 4%                                                                                                                                                                         |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                            |
| Acceptance criteria | Deployment `broken-deploy` in namespace `broken-ns` has an incorrect container image and pods are failing.<br/>- Fix the image to `nginx:alpine`<br/>- Ensure `2` ready replicas |
---
|        **7**        | **Install an application with Helm**                                                                                                                                                                                   |
| :-----------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 8%                                                                                                                                                                                                                     |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                        |
| Acceptance criteria | - Add Helm repository `bitnami` using URL `https://charts.bitnami.com/bitnami`<br/>- Create namespace `helm-ns`<br/>- Install chart `bitnami/nginx` as release name `nginx-web` in namespace `helm-ns`<br/>- Set `replicaCount=2` |
---
|        **8**        | **Deploy an application with Kustomize**                                                                                                                                                                                                                                                                  |
| :-----------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 8%                                                                                                                                                                                                                                                                                                        |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                                           |
| Acceptance criteria | Base kustomize files exist at `/home/ubuntu/kustomize/base/`.<br/>Create a production overlay at `/home/ubuntu/kustomize/overlays/prod/kustomization.yaml` that:<br/>- Inherits resources from base<br/>- Sets namespace to `kust-ns`<br/>- Patches replicas to `3`<br/>Apply the overlay to the cluster. Namespace `kust-ns` already exists. |
---
|        **9**        | **Blue/Green deployment**                                                                                                                                                                                                                                                                |
| :-----------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 8%                                                                                                                                                                                                                                                                                       |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                          |
| Acceptance criteria | Deployment `app-blue` (image=`nginx:alpine`, label `version=blue`, replicas=`2`) and Service `app-svc` (selector: `version=blue`) already exist in namespace `bg-ns`.<br/>- Create Deployment `app-green` (image=`viktoruj/ping_pong:alpine`, label `version=green`, replicas=`2`)<br/>- Switch Service `app-svc` selector to `version=green` |
---
|       **10**        | **Canary deployment**                                                                                                                                                                                                                                                                                                          |
| :-----------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|     Task weight     | 6%                                                                                                                                                                                                                                                                                                                             |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                                                                |
| Acceptance criteria | Deployment `main-app` (`4` replicas, labels `app=frontend,track=stable`, image=`nginx:alpine`) and Service `frontend-svc` (selector: `app=frontend`) already exist in namespace `canary-ns`.<br/>Create Deployment `canary-app` with `1` replica, labels `app=frontend,track=canary`, image=`viktoruj/ping_pong:alpine` in namespace `canary-ns`. |
---
|       **11**        | **Create a ClusterIP Service**                                                                                                                                                    |
| :-----------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 2%                                                                                                                                                                                |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                   |
| Acceptance criteria | Deployment `web-app` (label `app=web-app`) already exists in namespace `svc-ns`.<br/>Create Service `web-svc` type=`ClusterIP` port=`80` targetPort=`80` selector=`app=web-app` |
---
|       **12**        | **Create a NodePort Service**                                                                                                                                                        |
| :-----------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 2%                                                                                                                                                                                   |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                      |
| Acceptance criteria | Deployment `np-app` (label `app=np-app`) already exists in namespace `np-ns`.<br/>Create Service `np-svc` type=`NodePort` port=`80` targetPort=`80` nodePort=`30091` selector=`app=np-app` |
---
|       **13**        | **Create an Ingress with host routing**                                                                                                                                                                                      |
| :-----------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 4%                                                                                                                                                                                                                           |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                              |
| Acceptance criteria | Deployment `web-deploy` and Service `web-svc` (port=`80`) already exist in namespace `ingress-basic-ns`.<br/>Create Ingress `web-ingress` with:<br/>- host: `web.example.com`<br/>- path: `/` (pathType: `Prefix`)<br/>- backend: `web-svc:80` |
---
|       **14**        | **Create a multi-path Ingress**                                                                                                                                                                                                                                                   |
| :-----------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 6%                                                                                                                                                                                                                                                                                |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                   |
| Acceptance criteria | Services `api-svc` (port=`8080`) and `web-svc` (port=`80`) already exist in namespace `ingress-multi-ns`.<br/>Create Ingress `multi-ingress` (no host required) with:<br/>- path `/api` (pathType: `Prefix`) → `api-svc:8080`<br/>- path `/web` (pathType: `Prefix`) → `web-svc:80` |
---
|       **15**        | **Fix a broken Ingress**                                                                                                                                                                                                       |
| :-----------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|     Task weight     | 4%                                                                                                                                                                                                                             |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                |
| Acceptance criteria | Ingress `broken-ingress` in namespace `ingress-fix-ns` points to a non-existent service `wrong-svc`.<br/>Service `correct-svc` exists on port `80`.<br/>Fix the Ingress to point to `correct-svc:80`. |
---
|       **16**        | **Create a NetworkPolicy to restrict pod traffic**                                                                                                                                                                                                                                                            |
| :-----------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 8%                                                                                                                                                                                                                                                                                                              |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                                                 |
| Acceptance criteria | In namespace `netpol-ns` there are pods: `frontend` (label: `role=frontend`), `backend` (label: `role=backend`), `other` (label: `role=other`).<br/>Create a NetworkPolicy `allow-frontend` that:<br/>- Allows ingress to `backend` pods from `frontend` pods only on port `8080`<br/>- Denies all other ingress to `backend` pods |
---
|       **17**        | **Create a cross-namespace NetworkPolicy**                                                                                                                                                                                                                                                                    |
| :-----------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 6%                                                                                                                                                                                                                                                                                                            |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                                               |
| Acceptance criteria | Namespace `app-ns` has Deployment `webapp` (label `app=webapp`) serving on port `8080`. Namespaces `trusted-ns` and `untrusted-ns` each have a test pod.<br/>- Add label `access=trusted` to namespace `trusted-ns`<br/>- Create NetworkPolicy `allow-trusted` in namespace `app-ns` that allows ingress only from namespaces with label `access=trusted` |
---
|       **18**        | **Fix a broken Service**                                                                                                                                                                                          |
| :-----------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 4%                                                                                                                                                                                                                |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                   |
| Acceptance criteria | Deployment `web-deploy` (label `app=web-v2`) already exists in namespace `svc-fix-ns`.<br/>Service `web-svc` exists but has wrong selector (`app=web-v1`).<br/>Fix the Service selector to `app=web-v2` so that it routes traffic to the pods. |
---
|       **19**        | **Create a headless Service**                                                                                                                                                                        |
| :-----------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 4%                                                                                                                                                                                                   |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                      |
| Acceptance criteria | StatefulSet `db-stateful` (label `app=db-stateful`) already exists in namespace `headless-ns`.<br/>Create headless Service `db-headless`: clusterIP=`None`, port=`5432`, selector=`app=db-stateful` |
---
|       **20**        | **Create a Service and Ingress combination**                                                                                                                                                                                                                                            |
| :-----------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Task weight     | 6%                                                                                                                                                                                                                                                                                      |
|       Cluster       | cluster1 (`kubectl config use-context cluster1-admin@cluster1`)                                                                                                                                                                                                                         |
| Acceptance criteria | Deployment `final-app` (label `app=final-app`) already exists in namespace `final-ns` serving on port `8080`.<br/>- Create Service `final-svc` type=`ClusterIP` port=`80` targetPort=`8080` selector=`app=final-app`<br/>- Create Ingress `final-ingress` with host=`final.example.com`, path=`/` (Prefix) → `final-svc:80` |
---
