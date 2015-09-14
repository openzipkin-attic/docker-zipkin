This creates a patch to `zipkin-anormdb` that avoids HikariDB until it doesn't use `javax.beans` package.

https://github.com/brettwooldridge/HikariCP/issues/415

```bash
# compile a com.twitter.zipkin.storage.anormdb.DataSource that uses commons
curl -SL https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.4.2/commons-pool2-2.4.2.jar > commons-pool2.jar
curl -SL https://repo1.maven.org/maven2/org/apache/commons/commons-dbcp2/2.1.1/commons-dbcp2-2.1.1.jar > commons-dbcp2.jar
javac -cp commons-pool2.jar:commons-dbcp2.jar DataSource.java
git add DataSource.class
rm commons*
```
