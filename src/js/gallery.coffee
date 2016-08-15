$ = require 'jquery'
require 'foundation'
Gallery = require('../../require/gallery')
GalleryMainView = require('../../require/gallery-main-view')
Base = require '../../require/base'

Base.initialize '.session-menu', '.cart-summary-view'

galleryMainView = new GalleryMainView {model: new Gallery, el: '.gallery-main-view', cart: Base.cartItems}
galleryMainView.render()

$ ->
	Base.onLoad()

$(document).foundation()
