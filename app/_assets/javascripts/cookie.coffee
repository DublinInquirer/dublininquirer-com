$(document).on 'ready turbolinks:load', ->
  'use strict'

  $('[data-action="acceptCookies"]').on 'click', (e) ->
    noticeEl = $(e.currentTarget).parents('.notice:first')
    noticeEl.css 'bottom', '-100%'
    e.preventDefault()

    $.ajax
      url: '/accept'
      type: 'PUT'
      data: {}
      success: (data) ->
        return

    setTimeout ->
      noticeEl.detach()
    , 500
