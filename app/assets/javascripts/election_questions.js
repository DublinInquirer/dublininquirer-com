$(document).on('ready turbolinks:load', function() {
  'use strict';

  $('[data-behaviour="scroll"]').on('click', function(e) {
    var targetOffset;
    e.preventDefault();
    targetOffset = $($(e.currentTarget).attr('href')).offset().top;
    $('html, body').animate({
      scrollTop: targetOffset - 0
    }, 1000);
  });

  $('[data-behaviour="switchView"]').on('change', function(e) {
    var selectEl;
    var path;

    selectEl = $(e.currentTarget);
    path = selectEl.data('path') + selectEl.val();
    e.stopImmediatePropagation();

    // Turbolinks.visit(path);
    document.location.href = path;
  });
});