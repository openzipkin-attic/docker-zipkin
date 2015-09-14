package com.twitter.zipkin.storage.anormdb;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Temporarily until Hikari no longer uses the {@code java.beans} api.
 *
 * https://github.com/brettwooldridge/HikariCP/issues/415
 */
final class DataSource {

  private final org.apache.commons.dbcp2.BasicDataSource delegate;

  DataSource(String driver, String location, boolean jdbc3) {
    delegate = new org.apache.commons.dbcp2.BasicDataSource();
    delegate.setDriverClassName(driver);
    delegate.setUrl(location);
    delegate.setMaxTotal(32);
  }

  void close() throws SQLException {
    delegate.close();
  }

  Connection getConnection() throws SQLException {
    return delegate.getConnection();
  }
}

