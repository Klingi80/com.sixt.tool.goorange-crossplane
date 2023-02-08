# Install gator cli
https://open-policy-agent.github.io/gatekeeper/website/docs/gator/

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
```