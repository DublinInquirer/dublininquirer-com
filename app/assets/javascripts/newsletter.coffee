$(document).on 'ready turbolinks:load', ->
  'use strict'

  $('[data-action="closeNewsletterNotice"]').on 'click', (e) ->
    noticeEl = $(e.currentTarget).parents('.front-subscribe-newsletter')
    noticeEl.css 'bottom', '-100%'
    e.preventDefault()

    setTimeout ->
      noticeEl.detach()
    , 500
