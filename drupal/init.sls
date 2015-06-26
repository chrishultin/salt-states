{% set drupal_domain = salt['pillar.get']('drupal:domain', 'example.com') %}
{% set drupal_admin_user = salt['pillar.get']('drupal:admin_user', 'admin') %}
{% set drupal_admin_pass = salt['pillar.get']('drupal:admin_pass', 'Drup4lAdmin') %}

{% set drupal_db_host = salt['pillar.get']('drupal:db_host', 'localhost') %}
{% set drupal_db_name = salt['pillar.get']('drupal:db_name', 'drupal') %}
{% set drupal_db_user = salt['pillar.get']('drupal:db_user', 'drupal') %}
{% set drupal_db_pass = salt['pillar.get']('drupal:db_pass', 'drupalPass') %}

{% set mysql_root_password = salt['pillar.get']('mysql:root_password', '') %}

drupal-dependencies:
  pkg.installed:
    - pkgs:
      - php5
      - php5-mysql
      - php5-xmlrpc
      - php5-gd
      - php5-json
      - php5-apcu

# Depends on drush and MySQL
drupal-install:
  cmd.run:
    - name: |
        cd /var/www

        drush dl drupal --drupal-project-rename={{drupal_domain}}

        cd {{drupal_domain}}

        drush --yes site-install standard \
        --db-url='mysql://{{drupal_db_user}}:{{drupal_db_pass}}@{{drupal_db_host}}/{{drupal_db_name}}' \
        --db-su=root \
        --db-su-pw='{{mysql_root_password}}' \
        --site-name={{drupal_domain}} \
        --account-name=-{{drupal_admin_user}} \
        --account-pass={{drupal_admin_pass}} \
        --clean-url=0 -y

        chown -R www-data:www-data /var/www/{{drupal_domain}}
    - creates: /var/www/{{drupal_domain}}/index.php
