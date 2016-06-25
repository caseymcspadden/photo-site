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
Instafeed = require 'instafeed.js'

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}

featuredPhotos = new FeaturedPhotos

slideshowView = new SlideshowView({el: '.slideshow', collection: featuredPhotos, speed: 4000, pauseOnHover: true, showControls: false})

$('body').append loginView.render().el

feed = new Instafeed(
	get: 'user',
	userId: '727575',
	accessToken: '727575.6a15ce4.e9e018e14ae64aa1b2d7a48e9b580416'
	sortBy: 'most-recent'
	limit: 12
	template: '<div class="insta-container"><a href="{{link}}"><img src="{{image}}" /></a></div>'
)
feed.run()

$ ->
	session.fetch()
	featuredPhotos.fetch {reset: true}
	cartItems.fetch {reset: true}

$(document).foundation()
