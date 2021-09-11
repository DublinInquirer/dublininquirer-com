$(document).on 'ready turbolinks:load', ->
  'use strict'

  $('[data-action="closeNotice"]').on 'click', (e) ->
    noticeEl = $(e.currentTarget).parents('.notice:first')
    noticeEl.css 'bottom', '-100%'
    e.preventDefault()

    setTimeout ->
      noticeEl.detach()
    , 500
