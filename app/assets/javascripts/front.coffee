$(document).ready ->
  if $('body').scrollTop() > 145
    $('.meta-nav.-fixed').addClass('-open')
  else
    $('.meta-nav.-fixed').removeClass('-open')

  $(window).on 'scroll', ->
    if $('body').scrollTop() > 145
      $('.meta-nav.-fixed').addClass('-open')
    else
      $('.meta-nav.-fixed').removeClass('-open')

  $('[data-behaviour="scroll"]').on 'click', (e) ->
    targetOffset = $($(e.currentTarget).attr('href')).offset().top
    $('html, body').animate({scrollTop: (targetOffset - 80)});


  player = new Plyr('#player', controls: [
    'play'
    'progress'
    'current-time'
    'mute'
    'volume'
  ])