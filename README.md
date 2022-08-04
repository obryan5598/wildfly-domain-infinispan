# WildFly domain with external Infinispan

```
./run.sh

rm -f cookies ; curl -v -u 'user:password' -c cookies http://localhost:8080/appv1/ ; curl -v -u 'user:password' -b cookies http://localhost:8181/appv1/
```
