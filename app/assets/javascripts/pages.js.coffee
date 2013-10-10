# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

validate_email = (email) ->
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  return re.test(email)

set_error_message = (selector, message) ->
  #$(selector).after('<div class="error">' + message + '</div>')
  $.gritter.add({      
    title: 'Warning!',      
    text: message,
    image: 'assets/warning.png'
  });        

init_login_form = () ->
  $('#session_email').bind 'focus', (event) =>
    if $('#session_email').val() is 'Username' then $('#session_email').val('')
  $('#session_email').bind 'blur', (event) =>
    if $('#session_email').val() is '' then $('#session_email').val('Username')
  $('#session_password').bind 'focus', (event) =>
    if $('#session_password').val() is '******' then $('#session_password').val('')
  $('#session_password').bind 'blur', (event) =>
    if $('#session_password').val() is '' then $('#session_password').val('******')

validate_registration_form = () ->
  $('.registration-page input[type="submit"]').bind 'click', (event) =>
    result = true
    if $('#merchant_email').val() is ''
      result = false              
      set_error_message('#merchant_email', "email is empty")
    else if !validate_email $('#merchant_email').val()
      result = false
      set_error_message('#merchant_email', "email is not valid")
    if $('#merchant_bitcoin_address').val() is ''
      result = false
      set_error_message('#merchant_bitcoin_address', "bitcoin address is empty")
    if $('#merchant_password').val() is ''
      result = false
      set_error_message('#merchant_password', "password is empty")
    if $('#merchant_password_confirmation').val() isnt $('#merchant_password').val()
      result = false
      set_error_message('#merchant_password_confirmation', "passwords are not equal")
    return result

$ ->
  init_login_form()
  validate_registration_form()