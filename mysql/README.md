# mysql
This is a small mysql image which shares a base layer with other zipkin images.

When running with docker-machine, you can connect like so:

```bash
$ mysql -h $(docker-machine ip) -u zipkin -pzipkin -D zipkin
```
