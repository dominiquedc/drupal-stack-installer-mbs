; $Id$
;
; ----------------
; Multimediabs Make file
; ----------------

  
; Core version
; ------------
; Each makefile should begin by declaring the core version of Drupal that all
; projects should be compatible with.
  
core = 6.x
  
; API version
; ------------
; Every makefile needs to declare its Drush Make API version. This version of
; drush make uses API version `2`.
  
api = 2
  
; Core project
; ------------
; In order for your makefile to generate a full Drupal site, you must include
; a core project. This is usually Drupal core, but you can also specify
; alternative core projects like Pressflow. Note that makefiles included with
; install profiles *should not* include a core project.
  
; Use Pressflow instead of Drupal core:
projects[pressflow][type] = "core"
projects[pressflow][download][type] = "get"
projects[pressflow][download][url] = "http://launchpad.net/pressflow/6.x/6.20.97/+download/pressflow-6.20.97.tar.gz"
  
  
; Modules
; --------
projects[admin_menu][subdir] = contrib
projects[vertical_tabs][subdir] = contrib

projects[cck][subdir] = contrib
projects[filefield][subdir] = contrib
projects[imagefield][subdir] = contrib
projects[date][subdir] = contrib
projects[imageapi][subdir] = contrib
projects[imagecache][subdir] = contrib

projects[views][subdir] = contrib

projects[features][subdir] = contrib
projects[diff][subdir] = contrib

projects[pathauto][subdir] = contrib
projects[token][subdir] = contrib

projects[i18n][subdir] = contrib
projects[l10n_update][subdir] = contrib
projects[l10n_client][subdir] = contrib


;Development modules
projects[devel][subdir] = contrib
projects[coder][subdir] = contrib
projects[devel_themer][subdir] = contrib
projects[schema][subdir] = contrib
projects[install_profile_api][subdir] = contrib
projects[update_api][subdir] = contrib
projects[module_builder][subdir] = contrib

; Themes
; --------
 
  
; Libraries
; ---------





