<?php

function multimediabs_profile_modules() {
  return array(
    // core modules
    'menu', 'search', 'taxonomy', 'path', 'update', 'syslog', 'comment', 'locale', 'dblog',

    // cck
    'content', 'filefield', 'text', 'imagefield', 'date_api', 'date', 

    // imagecache
    'imageapi', 'imageapi_gd', 'imagecache', 'imagecache_ui',


    // pathauto,
    'pathauto', 'token',

    // views
    'views', 'views_ui',

    // admin improvements
    'admin_menu', 'vertical_tabs',
    
    //IPP
    'features', 'diff',
    
    //Languages
    'i18n', 'l10n_update', 'l10n_client', 
    
    // devel tools
    'coder', 'schema', 'install_profile_api', 'update_api', 'module_builder',
  );
}

function multimediabs_profile_details() {
  return array(
    'name' => 'Multimediabs pressflow',
    'description' => 'Installation drupal multimediabs Tours.'
  );
}

function multimediabs_profile_task_list() {
  $tasks = array();
  
  if (_l10n_install_language_selected()) {
    $tasks['l10n-install-batch'] = st('Download and import translations');
  }
   
  return $tasks;
}

function multimediabs_profile_tasks(&$task, $url) {
  global $install_locale;
  
  install_include(multimediabs_profile_modules());
  
  if ($task == 'profile') {
    // Perform the default profile install tasks.
    include_once('profiles/default/default.profile');
    default_profile_tasks($task, $url);
    
    // administration theme
    variable_set('admin_theme', 'garland');
    variable_set('node_admin_theme', TRUE);

    // user registration
    variable_set('user_register', FALSE);

    // hide all Garland blocks
    db_query("UPDATE {blocks} SET status = 0 WHERE theme = 'garland'");

    // image quality
    variable_set('image_jpeg_quality', 100);
    variable_set('imageapi_jpeg_quality', 100);

    // files
    variable_set('file_directory_temp', 'sites/default/tmp');
    variable_set('file_directory_path', 'sites/default/files');

    // date & time
    variable_set('configurable_timezones', 0);

    variable_set('date_format_short', 'd/m/Y - H:i');
    variable_set('date_format_short_custom', 'd/m/Y - H:i');

    variable_set('date_format_media', 'D, d/m/Y - H:i');
    variable_set('date_format_media_custom', 'D, d/m/Y - H:i');

    variable_set('date_format_long', 'l, j F, Y - H:i');
    variable_set('date_format_long_custom', 'l, j F, Y - H:i');

    // error reporting
    variable_set('error_level', 0);

    // roles
    db_query("INSERT INTO {role} (name) VALUES ('%s')", 'site administrator');
    db_query("INSERT INTO {role} (name) VALUES ('%s')", 'editor');

    // pathauto
    variable_set('pathauto_node_pattern', '');
    variable_set('pathauto_taxonomy_pattern', '');
    variable_set('pathauto_user_pattern', '');
    variable_set('pathauto_ignore_words', '');

    // permissions
    $admin_permissions = array('access administration menu', 'administer blocks', 'use PHP for block visibility', 'administer menu', 'access content', 'administer nodes', 'revert revisions', 'view revisions', 'administer url aliases', 'create url aliases', 'search content', 'use advanced search', 'access administration pages', 'access site reports', 'administer taxonomy', 'access user profiles', 'administer permissions', 'administer users');
    $editor_permissions = array('access administration menu', 'administer menu', 'access content', 'administer nodes', 'revert revisions', 'view revisions', 'search content', 'use advanced search', 'access administration pages');
    _multimediabs_add_permissions(3, $admin_permissions);
    _multimediabs_add_permissions(4, $editor_permissions);

    // input format permissions
    db_query("UPDATE {filter_formats} SET roles = ',4,3,' WHERE format IN (2, 3)");

    // hide module descriptions for admin
    db_query("UPDATE {users} SET data = '%s' WHERE uid = 1", serialize(array('admin_compact_mode' => TRUE)));

    // Update the menu router information.
    menu_rebuild();

    //Activate devel
    drupal_install_modules(array('devel', 'devel_themer'));
    
    // Move forward to our install batch.
    $task = 'l10n-install';
  }

  // Download and import translations if needed.
  if ($task == 'l10n-install') {
    if (_l10n_install_language_selected()) {
      $history = l10n_update_get_history();
      module_load_include('check.inc', 'l10n_update');
      $available = l10n_update_available_releases();
      $updates = l10n_update_build_updates($history, $available);

      module_load_include('batch.inc', 'l10n_update');
      $updates = _l10n_update_prepare_updates($updates, NULL, array());
      $batch = l10n_update_batch_multiple($updates, LOCALE_IMPORT_KEEP);

      // Overwrite batch finish callback, so we can modify install task too.
      $batch['finished'] = '_l10n_install_batch_finished';

      // Start a batch, switch to 'l10n-install-batch' task. We need to
      // set the variable here, because batch_process() redirects.
      variable_set('install_task', 'l10n-install-batch');
      batch_set($batch);
      batch_process($url, $url);
    }
  }

  if ($task == 'l10n-install-batch') {
    include_once 'includes/batch.inc';
    return _batch_page();
  }
}

function multimediabs_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {
    $form['site_information']['site_name']['#default_value'] = 'MBS';
    $form['site_information']['site_mail']['#default_value'] = ini_get('sendmail_from') ? ini_get('sendmail_from') : 'info@orangembs.fr';
    $form['admin_account']['account']['name']['#default_value'] = 'admin';
    $form['admin_account']['account']['mail']['#default_value'] = 'info@orangembs.fr';
  }
}

function _multimediabsformat_set_roles($roles, $format_id) {
  $roles = implode(',',$roles);
  // Drupal core depends on the list of roles beginning and ending with commas.
  if (!empty($roles)) {
    $roles = ','. $roles .',';
  }
  db_query("UPDATE {filter_formats} SET roles = '%s' WHERE format = %d", $roles, $format_id);
}

function _multimediabs_add_permissions($rid, $perms) {
  // Retrieve the currently set permissions.
  $result = db_query("SELECT p.perm FROM {role} r INNER JOIN {permission} p ON p.rid = r.rid WHERE r.rid = %d ", $rid);
  $existing_perms = array();
  while ($row = db_fetch_object($result)) {
    $existing_perms += explode(', ', $row->perm);
  }
  // If this role already has permissions, merge them with the new permissions being set.
  if (count($existing_perms) > 0) {
    $perms = array_unique(array_merge($perms, (array)$existing_perms));
  }

  // Update the permissions.
  db_query('DELETE FROM {permission} WHERE rid = %d', $rid);
  db_query("INSERT INTO {permission} (rid, perm) VALUES (%d, '%s')", $rid, implode(', ', $perms));
}

/**
 * Check whether we are installing in a language other than English.
 */
function _l10n_install_language_selected() {
  global $install_locale;
  return !empty($install_locale) && ($install_locale != 'en');
}

/**
 * Batch finish callback for l10n_install batches.
 */
function _l10n_install_batch_finished($success, $results) {
  if ($success) {
    variable_set('install_task', 'profile-finished');
  }
  // Invoke default batch finish function too.
  module_load_include('batch.inc', 'l10n_update');
  _l10n_update_batch_finished($success, $results);

  // Set up l10n_client and inform the admin about it.
  // @todo This message will not show up for some reason.
  global $user;
  variable_set('l10n_client_use_server', 1);
  variable_set('l10n_client_server', 'http://localize.drupal.org');
  drupal_set_message(t('Localization client is set up to share your translations with <a href="@localize">localize.drupal.org</a>. Each participating user should have a localize.drupal.org account and set up their API key on their user profile page. <a href="@edit-profile">Set up yours</a>.', array('@localize' => 'http://localize.drupal.org', '@edit-profile' => url('user/' . $user->uid . '/edit'))));
  
  //Set language defaults
  variable_set('language_negotiation', 1);
  db_query("UPDATE {variable} SET value = '%s' WHERE name = '%s'", 'O:8:"stdClass":11:{s:8:"language";s:2:"en";s:4:"name";s:7:"English";s:6:"native";s:7:"English";s:9:"direction";s:1:"0";s:7:"enabled";i:1;s:7:"plurals";s:1:"0";s:7:"formula";s:0:"";s:6:"domain";s:0:"";s:6:"prefix";s:0:"";s:6:"weight";s:1:"0";s:10:"javascript";s:0:"";}', 'language_default');
  
  global $theme_key;
  $theme_key = 'garland';
  _block_rehash();
  install_set_block('locale', '0', 'garland', 'left');
}
