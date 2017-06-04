<?php

function getConfig($name, $default = '')
{
  $secretFile = '/run/secrets/' . strtolower($name);
  if (file_exists($secretFile)) {
    return file_get_contents($secretFile);
  }
  if (isset($_ENV[$name])) {
    return $_ENV[$name];
  }

  return $default;
}

$env = include('/var/www/magento2/app/etc/env.org');

$env['backend']['frontName'] = getConfig('MAGENTO2_BACKEND_FRONTNAME', $env['backend']['frontName']);

$env['db']['connection']['default']['host'] = getConfig('MAGENTO2_DB_HOST', $env['db']['connection']['default']['host']);
$env['db']['connection']['default']['dbname'] = getConfig('MAGENTO2_DB_NAME', $env['db']['connection']['default']['dbname']);
$env['db']['connection']['default']['username'] = getConfig('MAGENTO2_DB_USER', $env['db']['connection']['default']['username']);
$env['db']['connection']['default']['password'] = getConfig('MAGENTO2_DB_PASS', $env['db']['connection']['default']['password']);

if (getConfig('MAGENTO2_REDIS_HOST') != '') {
  $env['cache'] = array(
    'frontend' => array(
      'default' => array(
        'backend' => 'Cm_Cache_Backend_Redis',
        'backend_options' => array(
          'server' => getConfig('MAGENTO2_REDIS_HOST'),
          'database' => getConfig('MAGENTO2_REDIS_DB_DEFAULT', '0'),
          'port' => getConfig('MAGENTO2_REDIS_PORT', '6379')
        ),
      ),
      'page_cache' => array(
        'backend' => 'Cm_Cache_Backend_Redis',
        'backend_options' => array(
          'server' => getConfig('MAGENTO2_REDIS_HOST'),
          'port' => getConfig('MAGENTO2_REDIS_PORT', '6379'),
          'database' => getConfig('MAGENTO2_REDIS_DB_PAGECACHE', '1'),
          'compress_data' => '0'
        )
      )
    )
  );

  $env['session'] = array(
    'save' => 'redis',
    'redis' => array(
      'host' => getConfig('MAGENTO2_REDIS_HOST'),
      'port' => getConfig('MAGENTO2_REDIS_PORT', '6379'),
      'password' => '',
      'timeout' => '2.5',
      'persistent_identifier' => '',
      'database' => getConfig('MAGENTO2_REDIS_DB_SESSION', '2'),
      'compression_threshold' => '2048',
      'compression_library' => 'gzip',
      'log_level' => '1',
      'max_concurrency' => '6',
      'break_after_frontend' => '5',
      'break_after_adminhtml' => '30',
      'first_lifetime' => '600',
      'bot_first_lifetime' => '60',
      'bot_lifetime' => '7200',
      'disable_locking' => '0',
      'min_lifetime' => '60',
      'max_lifetime' => '2592000'
    )
  );

}

if (getConfig('MAGENTO2_VARNISH_HOST') != '') {
  $env['http_cache_hosts'] = array(
    0 => array(
      'host' => getConfig('MAGENTO2_VARNISH_HOST'),
      'port' => getConfig('MAGENTO2_VARNISH_PORT', '80'),
    ),
    1 => array(
      'host' => getConfig('MAGENTO2_VARNISH_HOST'),
      'port' => getConfig('MAGENTO2_VARNISH_PORT', '80'),
    )
  );
}

file_put_contents('/var/www/magento2/app/etc/env.php', join("\n", [
  '<?php',
  'return ' . var_export($env, true) . ';'
]));
