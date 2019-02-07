$ ->
  isCtrl = false

  document.onkeyup = (e) ->
    if e.keyCode == 17
      isCtrl = false

    $('.grid-overlay').hide()
    $('.baseline-overlay').hide()

  document.onkeydown = (e) ->
    if e.keyCode == 17
      isCtrl = true
    if e.keyCode == 71 and isCtrl == true
      $('.grid-overlay').show()
    if e.keyCode == 66 and isCtrl == true
      $('.baseline-overlay').show()

