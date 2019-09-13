setupStripePaymentMethodForm = (form) ->
  confirmPayment = (data) ->
    $.ajax
      url: '/gifts/confirm'
      type: 'POST'
      dataType: 'HTML'
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
        return
      data: data
      success: (data, status) ->
        window.location.href = "/gifts/thanks"
      error: (data, status) ->    
        window.location.href = "/failed_payment"
  registerElements = (elements, form) ->
    formButton = $(':submit', form)
    errorEl = $('.error:first', form)
    errorMessageEl = $('.message:first', errorEl)

    enableInputsAndButton = ->
      toggleInputDisalbed(false)
      formButton.prop('disabled', false)

    disableInputsAndButton = ->
      toggleInputDisalbed(true)
      formButton.prop('disabled', true)

    toggleInputDisalbed = (disabled) ->
      elements.forEach (element) ->
        element.update(disabled: disabled)

    elements.forEach (element) ->
      element.on 'change', (event) ->
        if event.error
          errorEl[0].classList.add 'visible'
          errorMessageEl.text event.error.message
        else
          errorEl[0].classList.remove 'visible'

    form.on 'submit', (e) ->
      e.preventDefault()
      form.addClass('submitting')
      disableInputsAndButton()
      stripe.createPaymentMethod('card', elements[0]).then (result) ->
        form.removeClass( 'submitting' )
        if result.paymentMethod
          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute('type', 'hidden')
          hiddenInput.setAttribute('name', 'payment_method_id')
          hiddenInput.setAttribute('value', result.paymentMethod.id)
          form[0].appendChild(hiddenInput)
          $.ajax
            type: 'POST'
            url: '/gifts'
            data: $(form).serializeArray()
            dataType: 'json'
            async: false
            success: (data, status) ->
              if data.status == 'requires_action'
                stripe.handleCardAction(data.payment_intent_client_secret).then (result) ->
                  if result.error
                    confirmPayment paymentIntentId: null
                  else
                    confirmPayment paymentIntentId: data.payment_intent_client_id
              else if data.status == 'succeeded'
                window.location.href = "/gifts/thanks"
              else
                window.location.href = "/failed_payment"
          return false
          form.addClass( 'submitted' )
        else
          enableInputsAndButton()
  elements = stripe.elements(
    fonts: [
      {
        family: 'Zirkon'
        src: 'url(https://d1trxack2ykyus.cloudfront.net/fonts/GT-Zirkon-Light.woff2)'
        style: 'normal'
        weight: '400'
      }
    ]
  )

  styles =
    base:
      color: '#070707'
      fontWeight: '400'
      fontFamily: '"Zirkon", sans-serif'
      fontSize: '17.5px'
      fontSmoothing: 'optimizeLegibility'
      ':focus': color: '#000'
      '::placeholder': color: '#999'
      ':focus::placeholder': color: '#DDD'
    invalid:
      color: '#FC4604'
      ':focus': color: '#070707'
      '::placeholder': color: '#FED1C0'

  classes =
    focus: '-focus'
    empty: '-empty'
    invalid: '-invalid'

  cardNumber = elements.create('cardNumber',
    style: styles
    classes: classes)
  cardNumber.mount '#stripe-form_card-number'
  cardExpiry = elements.create('cardExpiry',
    style: styles
    classes: classes)
  cardExpiry.mount '#stripe-form_card-expiry'
  cardCvc = elements.create('cardCvc',
    style: styles
    classes: classes)
  cardCvc.mount '#stripe-form_card-cvc'


  registerElements [ cardNumber, cardExpiry, cardCvc ], form

$(document).on 'ready turbolinks:load', ->
  'use strict'

  for subscriptionForm in $('.subscription-payment-method-form')
    setupStripePaymentMethodForm($(subscriptionForm))
