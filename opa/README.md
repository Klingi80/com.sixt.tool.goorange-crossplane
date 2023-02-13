# Install gator cli
https://open-policy-agent.github.io/gatekeeper/website/docs/gator/


# Apply policies
```bash
# we need to apply sync.yaml to replicate the data for 
# already existing resources in the gatekeeper audit
kubectl apply -f sync.yaml
kubectl apply -f namespace-with-label/.
kubectl apply -f onlycompositions/.
kubectl apply -f resource-already-managed-by-crossplane/.
kubectl apply -f service-name-pattern-match/.

```

# Run the test

```bash
cd namespace-with-label/tests
gator verify . -v
cd ../../onlycompositions/tests
gator verify . -v
cd ../../resource-already-managed-by-crossplane/tests
gator verify . -v
cd ../../service-name-pattern-match/tests
gator verify . -v
cd ../../namelength/tests
gator verify . -v
```