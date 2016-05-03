$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
FeaturedPhotos = require('../../require/featuredphotos')
SessionMenuView = require('../../require/session-menu-view')
SlideshowView = require('../../require/slideshow-view')
CartSummaryView = require('../../require/cart-summary-view')
CartItems = require('../../require/cartitems')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}

featuredPhotos = new FeaturedPhotos

slideshowView = new SlideshowView({el: '.slideshow', collection: featuredPhotos, speed: 4000, pauseOnHover: true, showControls: false})

$('body').append loginView.render().el

$ ->
	session.fetch()
	featuredPhotos.fetch {reset: true}
	cartItems.fetch {reset: true}

$(document).foundation()
