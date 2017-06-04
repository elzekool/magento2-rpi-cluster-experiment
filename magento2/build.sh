#!/bin/sh

# Clear build folder if it exists
rm -rf /data/build/magento2

# Authenticate with Magento repo
/usr/local/bin/composer config -g http-basic.repo.magento.com $REPO_USERNAME $REPO_PASSWORD

# Create project from meta package
/usr/local/bin/composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /data/build/magento2

# Copy auth.json to allow sampledata modules to be fetched and install sampledata
cp /data/.composer/auth.json /data/build//magento2/
/usr/local/bin/php /data/build/magento2/bin/magento sampledata:deploy
rm /data/build/magento2/auth.json

# ---------------------------------------
# From this point we need an active database, but we can almost be certain
# that it is available from this point as downloading the compose packages
# takes a while
# ---------------------------------------

# Install Magento2
# We use the database configuration for the install, not the end result
# Also the admin user we create here will be removed later so a save username/pass is not important
/usr/local/bin/php /data/build/magento2/bin/magento setup:install \
  --db-host="mariadb" \
  --db-password="magento2" \
  --admin-user="magento2" \
  --admin-password="m@gento2" \
  --admin-email="magento2@example.com" \
  --admin-firstname="Magento2" \
  --admin-lastname="Boys" \
  --use-rewrites="1" \
  --no-interaction

# Create and apply patch patch to fix an issue with zend-stdlib and Alpline
#
# See: https://github.com/magento/magento2/issues/2130
# See: https://github.com/zendframework/zend-stdlib/blob/b06c38ae2aaf0013878183699403b503cba9e26d/src/Glob.php#L64
cat >/data/build/stdlib-Glob.php.path <<EOL
--- vendor/zendframework/zend-stdlib/src/Glob.php
+++ vendor/zendframework/zend-stdlib/src/Glob.php
@@ -61,7 +61,7 @@
                 self::GLOB_NOSORT   => GLOB_NOSORT,
                 self::GLOB_NOCHECK  => GLOB_NOCHECK,
                 self::GLOB_NOESCAPE => GLOB_NOESCAPE,
-                self::GLOB_BRACE    => GLOB_BRACE,
+                self::GLOB_BRACE    => defined('GLOB_BRACE') ? GLOB_BRACE : 0,
                 self::GLOB_ONLYDIR  => GLOB_ONLYDIR,
                 self::GLOB_ERR      => GLOB_ERR,
             );
EOL
cd /data/build/magento2/ \
   && patch -p0 < /data/build/stdlib-Glob.php.path \
   && cd \
   && rm /data/build/stdlib-Glob.php.path

# Set Magento2 into production mode, this will trigger di:compile and setup:static-content:deploy
/usr/local/bin/php /data/build/magento2/bin/magento deploy:mode:set production

# Delete the magento2 user we created
cd /data/build/magento2/ \
   && /usr/local/bin/magerun2 admin:user:delete -f magento2 \
   && cd
