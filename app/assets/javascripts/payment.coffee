setupStripePaymentForm = (form) ->
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
      stripe.createToken(elements[0], {}).then (result) ->
        form.removeClass( 'submitting' )
        if result.token
          hiddenInput = document.createElement('input')
          hiddenInput.setAttribute('type', 'hidden')
          hiddenInput.setAttribute('name', 'stripe_token')
          hiddenInput.setAttribute('value', result.token.id)
          form[0].appendChild(hiddenInput)
          form.off 'submit'
          form.submit()
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

  for subscriptionForm in $('.subscription-form')
    setupStripePaymentForm($(subscriptionForm))
