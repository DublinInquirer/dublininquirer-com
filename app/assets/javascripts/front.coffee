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

  player = new Plyr('#player', controls: [
    'play'
    'progress'
    'current-time'
    'mute'
    'volume'
  ])