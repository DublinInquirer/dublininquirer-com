$(document).on('ready', function() {
  'use strict';

  $('[data-behaviour="token"]').select2();
  $('select#article_tag_ids').select2({
    ajax: {
      url: '/admin/tags/autocomplete',
      minimumInputLength: 2,
      processResults: function(data) {
        var i, len, tag, tags;
        tags = [];
        for (i = 0, len = data.length; i < len; i++) {
          tag = data[i];
          tags.push({
            id: tag.id,
            text: tag.name
          });
        }
        return {
          results: tags
        };
      }
    }
  });

  $('select#merge_tag_id').select2({
    ajax: {
      url: '/admin/tags/autocomplete',
      minimumInputLength: 2,
      processResults: function(data) {
        var i, len, tag, tags;
        tags = [];
        for (i = 0, len = data.length; i < len; i++) {
          tag = data[i];
          tags.push({
            id: tag.id,
            text: tag.name
          });
        }
        return {
          results: tags
        };
      }
    }
  });

  $('[data-action="submitForm"]').on('click', function(e) {
    $('form.admin-form:first').submit();
    return e.preventDefault();
  });
});