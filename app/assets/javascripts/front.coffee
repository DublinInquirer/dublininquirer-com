# sprinkles

$(document).ready ->
  if $(window).scrollTop() > 145
    $('.meta-nav.-fixed').addClass('-open')
  else
    $('.meta-nav.-fixed').removeClass('-open')

  $(window).on 'scroll', ->
    if $(window).scrollTop() > 145
      $('.meta-nav.-fixed').addClass('-open')
    else
      $('.meta-nav.-fixed').removeClass('-open')

  $('[data-behaviour="scroll"]').on 'click', (e) ->
    targetOffset = $($(e.currentTarget).attr('href')).offset().top
    e.preventDefault()
    $('html, body').animate({scrollTop: (targetOffset - 80)});

  for snowingEl, i in $('[data-behaviour="snowing"]')
    $(snowingEl).prepend($("<div class='snowing-bg'></div>"))
    $('.snowing-bg:last', $(snowingEl)).attr('id', 'snow-' + i)

    particlesJS 'snow-' + i,
      'particles':
        'number':
          'value': 250
          'density':
            'enable': true
            'value_area': 800
        'color': 'value': '#ffffff'
        'shape':
          'type': 'circle'
          'stroke':
            'width': 0
            'color': '#fff'
          'polygon': 'nb_sides': 4
          'image':
            'src': 0
            'width': 5
            'height': 5
        'opacity':
          'value': 0.5
          'random': false
          'anim':
            'enable': true
            'speed': 1
            'opacity_min': 0.1
            'sync': false
        'size':
          'value': 4
          'random': true
          'anim':
            'enable': true
            'speed': 1
            'size_min': 2
            'sync': false
        'line_linked':
          'enable': false
          'distance': 50
          'color': '#ffffff'
          'opacity': 0.6
          'width': 1
        'move':
          'enable': true
          'speed': 2
          'direction': 'bottom'
          'random': true
          'straight': false
          'out_mode': 'out'
          'bounce': false
          'attract':
            'enable': true
            'rotateX': 300
            'rotateY': 1200
      'interactivity':
        'detect_on': 'canvas'
        'events':
          'onhover':
            'enable': false
            'mode': 'repulse'
          'onclick':
            'enable': false
            'mode': 'push'
          'resize': true
        'modes':
          'grab':
            'distance': 400
            'line_linked': 'opacity': 1
          'bubble':
            'distance': 400
            'size': 40
            'duration': 2
            'opacity': 8
            'speed': 3
          'repulse':
            'distance': 200
            'duration': 0.4
          'push': 'particles_nb': 4
          'remove': 'particles_nb': 2
      'retina_detect': true

  player = new Plyr('#player', controls: [
    'play'
    'progress'
    'current-time'
    'mute'
    'volume'
  ])