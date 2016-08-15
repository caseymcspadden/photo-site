$ = require 'jquery'
require 'foundation'
#Backbone = require 'backbone'
FeaturedPhotos = require('../../require/featuredphotos')
SlideshowView = require('../../require/slideshow-view')
#FacebookView = require('../../require/facebook-view')
#InstagramView = require('../../require/instagram-view')
#Instafeed = require 'instafeed.js'
Base = require '../../require/base'

featuredPhotos = new FeaturedPhotos

slideshowView = new SlideshowView({el: '.slideshow', collection: featuredPhotos, speed: 4000, pauseOnHover: true, showControls: false})
#facebookView = new FacebookView {el: '.facebook-view'}
#instagramView = new InstagramView {el: '.instagram-view'}

Base.initialize '.session-menu', '.cart-summary-view'

#facebookView.render()
#instagramView.render()

$ ->
	Base.onLoad()
	featuredPhotos.fetch {reset: true}

$(document).foundation()
