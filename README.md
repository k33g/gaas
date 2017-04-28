# GaaS

## Run

```shell
mvn package
mvn exec:java

curl -H "Content-Type: application/json" -X POST -d\
 '{"code":"function res = -> 20*2+2"}'\
 http://goloasaservice.cleverapps.io/exec
```
