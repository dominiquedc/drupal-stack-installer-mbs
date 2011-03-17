

# set a higher memory limit, mandatory for Drupal 
ini_set('memory_limit',	            '64M');

# set the IPP environment as devel 
$conf['ipp_environment'] = 'developpement';

# set these Drupal variables as localized in each language
$conf['i18n_variables'] = array(   
  'site_name',
  'site_footer',
  'site_slogan',
  'site_mission',
  'anonymous',
  'theme_settings',
  'theme_garland_settings',
  'site_frontpage',
  'menu_primary_links_source',
  'menu_secondary_links_source',  
  'contact_form_information',  
  'user_mail_welcome_subject',
  'user_mail_welcome_body',
  'user_mail_approval_subject',
  'user_mail_approval_body',
  'user_mail_pass_subject',
  'user_mail_pass_body',   
  'user_mail_password_reset_body', 
  'user_mail_password_reset_subject',
  'user_mail_register_admin_created_body',
  'user_mail_register_admin_created_subject',
  'user_mail_register_no_approval_required_body',
  'user_mail_register_no_approval_required_subject',
  'user_mail_register_pending_approval_body',
  'user_mail_register_pending_approval_subject',
  'user_mail_status_activated_body',
  'user_mail_status_activated_subject',
  'user_mail_status_blocked_body',
  'user_mail_status_blocked_subject',
  'user_mail_status_deleted_body',
  'user_mail_status_deleted_subject',
  'user_picture_guidelines',
  'user_registration_help',
  'blog_help',
  'story_help',
);
