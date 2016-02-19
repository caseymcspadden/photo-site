$ = require 'jquery'
foundation = require 'foundation'
_ = require('underscore')
dropzone = require('dropzone')
Backbone = require('backbone')
PhotoCollection = require('../../require/photos')
FoldersView = require('../../require/folders-view')

$(document).foundation()

Photos = new PhotoCollection(photos)

console.log folders

foldersview = new FoldersView({el: '#foldersView', initfolders: folders })

$(".filedrop").dropzone
  url: "services/upload"
  uploadMultiple: true
  addRemoveLinks: false
  acceptedFiles: 'image/*'
  maxFileSize: 50

$('#uploadModal .close-button').click (e) ->
  console.log e
  $('.filedrop').html('')

if $('ul.mtree').length

  collapsed = true
  close_same_level = false
  duration = 400
  listAnim = true
  easing = 'easeOutQuart'

  $('.mtree ul').css
    'overflow':'hidden'
    'height': if collapsed then 0 else 'auto'
    'display': if collapsed then 'none' else 'block'

  #Get node elements, and add classes for styling
  node = $('.mtree li:has(ul)') 
    
  node.each (index,val) ->
    $(this).children(':first-child').css('cursor', 'pointer')
    $(this).addClass('mtree-node mtree-' + (if collapsed then 'closed' else 'open'))
    $(this).children('ul').addClass('mtree-level-' + ($(this).parentsUntil($('ul.mtree'), 'ul').length + 1))
   
    
  #Set mtree-active class on list items for last opened element
  $('.mtree li > *:first-child').on 'click.mtree-active', (e) ->
    console.log "This happened"
    if $(this).parent().hasClass('mtree-closed')
      $('.mtree-active').not($(this).parent()).removeClass('mtree-active')
      $(this).parent().addClass('mtree-active')
    else if $(this).parent().hasClass('mtree-open')
      $(this).parent().removeClass('mtree-active') 
    else
      $('.mtree-active').not($(this).parent()).removeClass('mtree-active')
      $(this).parent().toggleClass('mtree-active') 
        
  #Set node click elements, preferably <a> but node links can be <span> also
  node.children(':first-child').on 'click.mtree', (e) ->
        
    #element vars
    el = $(this).parent().children('ul').first()
    isOpen = $(this).parent().hasClass('mtree-open')

    console.log if isOpen then "Not open" else "Open"
        
    #close other elements on same level if opening 
    if (close_same_level or $('.csl').hasClass('active')) and not isOpen
      close_items = $(this).closest('ul').children('.mtree-open').not($(this).parent()).children('ul')

      if $.Velocity
        close_items.velocity 
          height: 0, {
            duration: duration
            easing: easing
            display: 'none'
            delay: 100
            complete: ->
              setNodeClass($(this).parent(), true)
          }
      else
        close_items.delay(100).slideToggle duration, ->
          setNodeClass($(this).parent(), true)
            
      #force auto height of element so actual height can be extracted
    el.css
      'height': 'auto'

    #listAnim: animate child elements when opening
    if not isOpen and $.Velocity and listAnim
      el.find(' > li, li.mtree-open > ul > li').css({'opacity':0}).velocity('stop').velocity('list');
      
    #Velocity.js animate element
    if $.Velocity
      el.velocity('stop').velocity {
          #translateZ: 0,
          height: if isOpen then [0, el.outerHeight()] else [el.outerHeight(), 0]
          },
          queue: false
          duration: duration
          easing: easing
          display: if isOpen then 'none' else 'block',
          begin: setNodeClass($(this).parent(), isOpen)
          complete: ->
            if not isOpen
              $(this).css('height', 'auto')
    #jQuery fallback animate element
    else
      setNodeClass($(this).parent(), isOpen)
      el.slideToggle(duration)
   
    e.preventDefault()
         
  #Function for updating node class
  setNodeClass = (el, isOpen) ->
    if isOpen
      el.removeClass('mtree-open').addClass('mtree-closed')
    else
      el.removeClass('mtree-closed').addClass('mtree-open')

  #List animation sequence
  if $.Velocity and listAnim
    $.Velocity.Sequences.list = (element, options, index, size) ->
      $.Velocity.animate element, { 
        opacity: [1,0],
        translateY: [0, -(index+1)]
        },
        delay: index*(duration/size/2)
        duration: duration,
        easing: easing

  if $('.mtree').css('opacity') == 0 
    if $.Velocity
      $('.mtree').css('opacity', 1).children().css('opacity', 0).velocity('list')
    else
      $('.mtree').show(200)

