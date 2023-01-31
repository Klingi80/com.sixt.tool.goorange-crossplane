# goorange-crossplane
GoOrange Platform Crossplane

# Details of XRD
* IRSA : This XRD is responsible to creating a role, a policy, a policy attachment with the role and a service account in the k8s cluster
* ObjectStorage : This XRD is responsible for creating a S3 bucket with public access blocked and sse enabled with AES256 algorithm
* ExtraPolicyAttachment : This XRD is reponisble for creating a new policy and attaching it to an existing Role to allow the Service account to have RW access on the S3 bucket

# Claims for developers
* IRSA
```
---
apiVersion: sixt.com/v1alpha1
kind: IRSA
metadata:
  name: <name of irsa which is used for creating the role and policy>
  namespace: <namespace where the bucket is claimed>
spec:
  compositionSelector:
    matchLabels:
      sixt.com/provider: aws
      sixt.com/environment: dev
      s3.sixt.com/configuration: standard
      crossplace.io/xrd: xirsas.sixt.com
  serviceAccountName: <name of the service account>
  bucketName: <name of the bucket which is used in the policy>
  k8sProviderConfigRef: kubernetes-provider-config
  resourceConfig:
    providerConfigName: aws-provider-config
```

# ObjectStorage
```
---
apiVersion: sixt.com/v1alpha1
kind: ObjectStorage
metadata:
  name: <name of the bucket>
  namespace: <namespace where the bucket is claimed>
spec:
  compositionSelector:
    matchLabels:
      sixt.com/provider: aws
      sixt.com/environment: dev
      s3.sixt.com/configuration: standard
      crossplace.io/xrd: xobjectstorages.sixt.com
  resourceConfig:
    name: <name of the bucket>
    providerConfigName: aws-provider-config
```

# ExtraPolicyAttachment
```
---
apiVersion: sixt.com/v1alpha1
kind: ExtraPolicyAttachment
metadata:
  name: <name prefix used to create the policy>
  namespace: <namespace where the bucket is claimed>
spec:
  compositionSelector:
    matchLabels:
      sixt.com/provider: aws
      sixt.com/environment: dev
      s3.sixt.com/configuration: standard
      crossplace.io/xrd: xextrapolicyattachments.sixt.com
  bucketName: <name of the bucket which is added in the policy>
  roleName: <name of the role previously created>
  resourceConfig:
    providerConfigName: aws-provider-config
```

## Testing

### Create Namespace

Using Kubernetes Provider
```bash
kubectl apply -f managed-resources/goorange/dev/team-A/namespace.yaml
```

### Create Bucket
Configure S3 XRD and Composition:
```bash
kubectl apply -f xrd/dev/s3/xrd.yaml
kubectl apply -f  composition/dev/s3/composition.yaml

```

Update BucketName `goorange-crossplane-example-bucket-16` with something random
Create s3 bucket with claim:
```
kubectl create ns crossplane-test-namespace || true
kubectl apply -f managed-resources/goorange/dev/team-A/s3.yaml
```

Check the Status of s3 claim
```bash
kubectl describe objectstorages.sixt.com -n crossplane-test-namespace
kubectl get objectstorages.sixt.com -n crossplane-test-namespace
```

### Create IRSA

Configure IRSA XRD and Composition
```bash
kubectl apply -f xrd/dev/irsa/xrd.yaml
kubectl apply -f  composition/dev/irsa/composition.yaml 
```

Update bucketname `bucketName: goorange-crossplane-example-bucket-16`
Create IRSA
```bash
kubectl apply -f  managed-resources/goorange/dev/team-A/irsa.yaml
```

Check the Status of irsa claim
```bash
kubectl describe irsas.sixt.com -n crossplane-test-namespace
kubectl get irsas.sixt.com -n crossplane-test-namespace
kubectl get sa -n crossplane-test-namespace
```

Upload a file or create folder in the bucket, then list bucket content
List the content of the bucket:
```bash
kubectl run tmp-cli -n crossplane-test-namespace --rm -ti --image=public.ecr.aws/aws-cli/aws-cli --overrides='{ "spec": { "serviceAccountName": "goorange-crossplane-example-bucket-16-irsa" }  }' -- s3 ls <bucket-name>
```

### Create Policy Attachments

Configure IRSA XRD and Composition
```bash
kubectl apply -f xrd/dev/policyattachment/xrd.yaml 
kubectl apply -f composition/dev/policyattachment/composition.yaml
```


Update `bucketName` and `roleName`
Create policy attachment usin claim
```bash
kubectl apply -f  managed-resources/goorange/dev/team-A/policyattachment.yaml 
```

Check Status
```bash
kubectl describe extrapolicyattachment.sixt.com -n crossplane-test-namespace
kubectl get extrapolicyattachment.sixt.com -n crossplane-test-namespace
```

### Clean Up

Delete all claims from namespace 
```bash
kubectl delete claim --all -n crossplane-test-namespace
```

Delete all XRDs and Compositions
```bash
kubectl delete -f xrd/dev/s3/xrd.yaml
kubectl delete -f  composition/dev/s3/composition.yaml
kubectl delete -f xrd/dev/irsa/xrd.yaml
kubectl delete -f  composition/dev/irsa/composition.yaml
kubectl delete -f xrd/dev/policyattachment/xrd.yaml 
kubectl delete -f composition/dev/policyattachment/composition.yaml
```