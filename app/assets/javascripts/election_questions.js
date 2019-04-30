$(document).on('ready turbolinks:load', function() {
  'use strict';

  $('[data-behaviour="scroll"]').on('click', function(e) {
    var targetOffset;
    e.preventDefault();
    targetOffset = $($(e.currentTarget).attr('href')).offset().top;
    return $('body').animate({
      scrollTop: targetOffset - 0
    }, 1000);
  });
});