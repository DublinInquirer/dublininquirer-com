$(document).on 'ready turbolinks:load', ->
  'use strict'

  $('[data-behaviour="token"]').select2()

  $('select#article_tag_ids').select2 ajax:
    url: '/admin/tags/autocomplete'
    minimumInputLength: 2
    processResults: (data) ->
      tags = []
      for tag in data
        tags.push {id: tag.id, text: tag.name}
      { results: tags }

  $('select#merge_tag_id').select2 ajax:
    url: '/admin/tags/autocomplete'
    minimumInputLength: 2
    processResults: (data) ->
      tags = []
      for tag in data
        tags.push {id: tag.id, text: tag.name}
      { results: tags }

  $('[data-action="submitForm"]').on 'click', (e) ->
    $('form.admin-form:first').submit()
    e.preventDefault()