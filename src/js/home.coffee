$ = require 'jquery'
require 'foundation'
#Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
FeaturedPhotos = require('../../require/featuredphotos')
SessionMenuView = require('../../require/session-menu-view')
SlideshowView = require('../../require/slideshow-view')
#FacebookView = require('../../require/facebook-view')
#InstagramView = require('../../require/instagram-view')
CartSummaryView = require('../../require/cart-summary-view')
CartItems = require('../../require/cartitems')
#Instafeed = require 'instafeed.js'

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}

featuredPhotos = new FeaturedPhotos

slideshowView = new SlideshowView({el: '.slideshow', collection: featuredPhotos, speed: 4000, pauseOnHover: true, showControls: false})
#facebookView = new FacebookView {el: '.facebook-view'}
#instagramView = new InstagramView {el: '.instagram-view'}

$('body').append loginView.render().el

#facebookView.render()
#instagramView.render()

$ ->
	session.fetch()
	featuredPhotos.fetch {reset: true}
	cartItems.fetch {reset: true}

$(document).foundation()
