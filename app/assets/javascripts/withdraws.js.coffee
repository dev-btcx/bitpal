# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
      
minimal_amount = 0.01
withdraw_fee_percent = 0.01
bitcoin_fee = 0.0005

set_error_message = (message) ->
  $.gritter.add({      
    title: 'Warning!',      
    text: message,
    image: '/assets/warning.png'
  });        
        
init_input_fields = (amount, fee, output) ->
  $('#withdraw_amount').val(amount)
  $('#withdraw_fee').val(fee)
  $('#withdraw_output').val(output)    
        
init_withdraw_fee = () ->
  limit = $("#withdraw_limit").val().replace(",",".")
  amount = limit
  fee = amount * withdraw_fee_percent + bitcoin_fee
  output = amount - fee
  init_input_fields amount, fee, output    
 
recalculate_output = () ->
  limit = $("#withdraw_limit").val().replace(",",".")
  amount = $('#withdraw_amount').val().replace(",",".")
  if (amount < minimal_amount || amount > limit) 
    init_withdraw_fee()
  else 
    fee = amount * withdraw_fee_percent + bitcoin_fee
    output = amount - fee
    init_input_fields amount, fee, output

recalculate_amount = () ->
  limit = $("#withdraw_limit").val().replace(",",".")
  output = Number($('#withdraw_output').val()).replace(",",".")
  amount = Number((output + bitcoin_fee)/(1 - withdraw_fee_percent))
  fee = Number(amount * withdraw_fee_percent + bitcoin_fee) 
  if (amount < minimal_amount || amount > limit) 
    init_withdraw_fee()
  else 
    init_input_fields amount, fee, output

check_withdraw = () ->
  limit = $("#withdraw_limit").val().replace(",",".")
  if (limit < minimal_amount)
     init_input_fields 0, 0, 0
     set_error_message("not enought money to perform withdraw!")
    
init_withdraw_form = () ->
  $('#withdraw_amount').bind 'change', (event) =>
    recalculate_output()
  $('#withdraw_output').bind 'change', (event) =>
    recalculate_amount()    
    
$ ->
  init_withdraw_fee()
  init_withdraw_form()  
  check_withdraw()
