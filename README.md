# goorange-crossplane
GoOrange Platform Crossplane

# Details of XRD
* S3WithIrsa: This XRD is responsible to creating a bucket, a role, a policy, a policy attachment with the role and a service account in the k8s cluster
* S3WithPolicyAttachment : This XRD is responsible for creating a S3 bucket with public access blocked and sse enabled with AES256 algorithm and for creating a new policy and attaching it to an existing Role to allow the Service account to have RW access on the S3 bucket

# Claims for developers

# S3WithIRSA
```
---
apiVersion: sixt.com/v1alpha1
kind: S3WithIRSA
metadata:
  name: goorange-s3-with-irsa-example
  namespace: crossplane-test-namespace
spec:
  resourceConfig:
    bucketName: goorange-s3-with-irsa-example-bucket
    serviceName: com-sixt-service-test
```

# S3WithPolicyAttachment
```
---
apiVersion: sixt.com/v1alpha1
kind: S3WithPolicyAttachment
metadata:
  name: goorange-s3-with-policy-attachment-example
  namespace: crossplane-test-namespace
spec:
  resourceConfig:
    bucketName: goorange-s3-with-policy-attachment-example-bucket
    serviceName: com-sixt-service-test
```

## Testing

### Create Namespace

Using Kubernetes Provider
```bash
kubectl apply -f managed-resources/goorange/dev/team-A/namespace.yaml
```

### Create S3WithIRSA

Configure S3WithIRSA XRD and Composition
```bash
kubectl apply -f xrd/dev/s3WithIrsa/xrd.yaml
kubectl apply -f composition/s3WithIrsa/irsa/composition.yaml 
```

Update bucketname and serviceName

`bucketName: goorange-crossplane-example-bucket-16`

`serviceName: service-name-with-hyphen`

Create S3WithIRSA
```bash
kubectl apply -f  managed-resources/goorange/dev/team-A/s3WithIrsa.yaml
```

Check the Status of S3WithIRSA claim
```bash
kubectl describe s3WithIrsa.sixt.com -n crossplane-test-namespace
kubectl get s3WithIrsa.sixt.com -n crossplane-test-namespace
kubectl get sa -n crossplane-test-namespace
```

Upload a file or create folder in the bucket, then list bucket content
List the content of the bucket:
```bash
kubectl run tmp-cli -n crossplane-test-namespace --rm -ti --image=public.ecr.aws/aws-cli/aws-cli --overrides='{ "spec": { "serviceAccountName": "goorange-crossplane-example-bucket-16-irsa" }  }' -- s3 ls <bucket-name>
```

### Create S3WithPolicyAttachment

Configure S3WithPolicyAttachment XRD and Composition
```bash
kubectl apply -f xrd/dev/s3WithPolicyAttachment/xrd.yaml 
kubectl apply -f composition/dev/s3WithPolicyAttachment/composition.yaml
```


Update bucketname and serviceName

`bucketName: goorange-crossplane-example-bucket-16`

`serviceName: service-name-with-hyphen`

Check Status
```bash
kubectl describe s3withpolicyattachment.sixt.com -n crossplane-test-namespace
kubectl get s3withpolicyattachment.sixt.com -n crossplane-test-namespace -w # wait for the SYNCED and READY status to be True
```

### Clean Up

Delete all claims from namespace 
```bash
kubectl delete claim --all -n crossplane-test-namespace
```

Delete all XRDs and Compositions
```bash
kubectl delete -f xrd/dev/s3WithIrsa/xrd.yaml
kubectl delete -f composition/dev/s3WithIrsa/composition.yaml
kubectl delete -f xrd/dev/s3WithPolicyAttachment/xrd.yaml 
kubectl delete -f composition/dev/s3WithPolicyAttachment/composition.yaml
```

# Existing Policies on Gatekeeper

* An OPA policy will be deployed to validate the serviceName is of the pattern for kind S3withIRSA and S3WithPolicyAttachment com-sixt-(service|api-v[1-9]{1})-[-a-z]+
* An OPA policy to validate the namespace has a label allowXRD
* An OPA policy to only allow claims against composition managed by SRE team. This will block claims which are created directly via upbound api
* An OPA policy to verify that a bucketName is not re-used for an already existing resource from S3WithIRSA or S3WithPolicyAttachment.