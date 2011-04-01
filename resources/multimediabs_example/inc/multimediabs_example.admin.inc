<?php

// $Id: multimediabs_example.admin.inc Exp $

//This file contains all admin settings forms

/**
 * The settings form for the module
 */
function multimediabs_example_settings_form() {
 
  $form['multimediabs_example']['multimediabs_example_text'] = array(
    '#type' => 'textfield',
    '#title' => t('Multimediabs example text'),
    '#default_value' => variable_get('multimediabs_example_text', 'Hello mbs'),
  );
  
  $form['multimediabs_example']['multimediabs_example_promoted'] = array(
    '#type' => 'select',
    '#options' => array(true => 'true', false => 'false'),
    '#title' => t('Multimediabs example promoted'),
    '#default_value' => variable_get('multimediabs_example_promoted', false),
  );
  
  return system_settings_form($form); 
}