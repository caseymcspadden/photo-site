$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
FeaturedPhotos = require('../../require/featuredphotos')
SessionMenuView = require('../../require/session-menu-view')
SlideshowView = require('../../require/slideshow-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

featuredPhotos = new FeaturedPhotos

slideshowView = new SlideshowView({el: '.slideshow', collection: featuredPhotos})

session.fetch()

$('body').append loginView.render().el

$ ->
	featuredPhotos.fetch {reset: true}

$(document).foundation()
