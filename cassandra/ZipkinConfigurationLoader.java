import org.apache.cassandra.config.Config;
import org.apache.cassandra.config.ConfigurationLoader;
import org.apache.cassandra.config.EncryptionOptions;
import org.apache.cassandra.config.ParameterizedClass;
import org.apache.cassandra.exceptions.ConfigurationException;

import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * This is an alternative configuration loader that works with Docker and the Zulu JRE.
 *
 * We override defaults by setting the listen address to the docker container (as opposed to the
 * underlying host). Without this change, other containers won't be able to communicate.
 * 
 * The default configuration loader uses snakeyaml, which uses the {@code java.beans} package, not
 * present in the JDK. Since we are using the slim Zulu JRE, we need an alternative. Ideally, this
 * would be simple, but since the configuration set in cassandra.yaml isn't the same as the defaults
 * in the {@link Config} constructor, we add all of them explicitly. If we get to the point to
 * maintaining this, we could switch this to use simple-json, but for now hard-coding is the
 * quickest.
 *
 * https://bitbucket.org/asomov/snakeyaml/issues/315/make-javabeans-optional-or-not-used
 */
public final class ZipkinConfigurationLoader implements ConfigurationLoader {

  @Override
  public Config loadConfig() throws ConfigurationException {
    try {
      Config config = valuesFromCassandraYaml();
      String ip = dockerContainerIp();
      config.rpc_address = "0.0.0.0";
      config.listen_address = ip;
      config.broadcast_rpc_address = ip;
      Map<String, String> parameters = new LinkedHashMap<>();
      parameters.put("seeds", ip);
      config.seed_provider.parameters = parameters;
      return config;
    } catch (SocketException e) {
      throw new ConfigurationException("couldn't get host ip", e);
    }
  }

  /** This gets the container IP without trying to lookup its name. */
  // http://stackoverflow.com/questions/8765578/get-local-ip-address-without-connecting-to-the-internet
  private static String dockerContainerIp() throws SocketException {
    return Collections.list(NetworkInterface.getNetworkInterfaces()).stream()
        .flatMap(i -> Collections.list(i.getInetAddresses()).stream())
        .filter(ip -> ip instanceof Inet4Address && ip.isSiteLocalAddress())
        .findAny().orElseThrow(SocketException::new)
        .getHostAddress();
  }

  /** Exactly the same values from {@code cassandra.yaml}, hard-coded as they don't match defaults. */
  private static Config valuesFromCassandraYaml() {
    Config config = new Config();
    config.cluster_name = "Test Cluster";
    config.num_tokens = 256;
    config.hinted_handoff_enabled = "true";
    config.hinted_handoff_throttle_in_kb = 1024;
    config.max_hints_delivery_threads = 2;
    config.batchlog_replay_throttle_in_kb = 1024;
    config.authenticator = "AllowAllAuthenticator";
    config.authorizer = "AllowAllAuthorizer";
    config.permissions_validity_in_ms = 2000;
    config.partitioner = "org.apache.cassandra.dht.Murmur3Partitioner";
    config.disk_failure_policy = Config.DiskFailurePolicy.stop;
    config.commit_failure_policy = Config.CommitFailurePolicy.stop;
    config.key_cache_size_in_mb = null;
    config.key_cache_save_period = 14400;
    config.row_cache_size_in_mb = 0;
    config.row_cache_save_period = 0;
    config.counter_cache_size_in_mb = null;
    config.counter_cache_save_period = 7200;
    config.commitlog_sync = Config.CommitLogSync.periodic;
    config.commitlog_sync_period_in_ms = 10000;
    config.commitlog_segment_size_in_mb = 32;
    LinkedHashMap<String, Object> seed_provider = new LinkedHashMap<>();
    seed_provider.put("class_name", "org.apache.cassandra.locator.SimpleSeedProvider");
    Map<String, String> parameters = new LinkedHashMap<>();
    parameters.put("seeds", "127.0.0.1");
    seed_provider.put("parameters", Arrays.asList(parameters));
    config.seed_provider = new ParameterizedClass(seed_provider);
    config.concurrent_reads = 32;
    config.concurrent_writes = 32;
    config.concurrent_counter_writes = 32;
    config.memtable_allocation_type = Config.MemtableAllocationType.heap_buffers;
    config.index_summary_capacity_in_mb = null;
    config.index_summary_resize_interval_in_minutes = 60;
    config.trickle_fsync = false;
    config.trickle_fsync_interval_in_kb = 10240;
    config.storage_port = 7000;
    config.ssl_storage_port = 7001;
    config.listen_address = "localhost";
    config.start_native_transport = true;
    config.native_transport_port = 9042;
    config.start_rpc = true;
    config.rpc_address = "localhost";
    config.rpc_port = 9160;
    config.rpc_keepalive = true;
    config.rpc_server_type = "sync";
    config.thrift_framed_transport_size_in_mb = 15;
    config.incremental_backups = false;
    config.snapshot_before_compaction = false;
    config.auto_snapshot = true;
    config.tombstone_warn_threshold = 1000;
    config.tombstone_failure_threshold = 100000;
    config.column_index_size_in_kb = 64;
    config.batch_size_warn_threshold_in_kb = 5;
    config.compaction_throughput_mb_per_sec = 16;
    config.compaction_large_partition_warning_threshold_mb = 100;
    config.sstable_preemptive_open_interval_in_mb = 50;
    config.read_request_timeout_in_ms = 5000L;
    config.range_request_timeout_in_ms = 10000L;
    config.write_request_timeout_in_ms = 2000L;
    config.counter_write_request_timeout_in_ms = 5000L;
    config.cas_contention_timeout_in_ms = 1000L;
    config.truncate_request_timeout_in_ms = 60000L;
    config.request_timeout_in_ms = 10000L;
    config.cross_node_timeout = false;
    config.endpoint_snitch = "SimpleSnitch";
    config.dynamic_snitch_update_interval_in_ms = 100;
    config.dynamic_snitch_reset_interval_in_ms = 600000;
    config.dynamic_snitch_badness_threshold = 0.1;
    config.request_scheduler = "org.apache.cassandra.scheduler.NoScheduler";
    EncryptionOptions.ServerEncryptionOptions server_encryption_options = new EncryptionOptions.ServerEncryptionOptions();
    server_encryption_options.internode_encryption = EncryptionOptions.ServerEncryptionOptions.InternodeEncryption.none;
    server_encryption_options.keystore = "conf/.keystore";
    server_encryption_options.keystore_password = "cassandra";
    server_encryption_options.truststore = "conf/.truststore";
    server_encryption_options.truststore_password = "cassandra";
    config.server_encryption_options = server_encryption_options;
    EncryptionOptions.ClientEncryptionOptions client_encryption_options = new EncryptionOptions.ClientEncryptionOptions();
    client_encryption_options.enabled = false;
    client_encryption_options.keystore = "conf/.keystore";
    client_encryption_options.keystore_password = "cassandra";
    config.client_encryption_options = client_encryption_options;
    config.internode_compression = Config.InternodeCompression.all;
    config.inter_dc_tcp_nodelay = false;
    return config;
  }
}
