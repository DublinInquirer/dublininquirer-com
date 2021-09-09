$(document).on 'ready turbolinks:load', ->
  'use strict'

  $('[data-action="closeNewsletterNotice"]').on 'click', (e) ->
    noticeEl = $(e.currentTarget).parents('.front-subscribe-newsletter')
    noticeEl.css 'bottom', '-100%'
    e.preventDefault()

    $.ajax
      url: '/dismiss-newsletter-subscribe'
      type: 'PUT'
      data: {}
      success: (data) ->
        return

    setTimeout ->
      noticeEl.detach()
    , 500
