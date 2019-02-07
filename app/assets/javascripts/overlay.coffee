$(document).on 'ready turbolinks:load', ->
  'use strict'

  $('[data-action="openOverlay"]').on 'click', (e) ->
    overlayEl = $('#' + $(e.currentTarget).data('target'))
    overlayEl.show()

    setTimeout ->
      $('body').addClass('-overlay-open')
      overlayEl.addClass '-open'
      e.preventDefault()
      $('[type="text"]:first', overlayEl).focus()
    , 25

  $('[data-action="closeOverlay"]').on 'click', (e) ->
    overlayEl = $(e.currentTarget).parents('[role="overlay"]:first')
    $('body').removeClass('-overlay-open')
    overlayEl.removeClass '-open'
    e.preventDefault()
    setTimeout ->
        overlayEl.hide()
    , 250
