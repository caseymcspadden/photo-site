$ = require 'jquery'
require 'foundation'
ContactView = require '../../require/contact-view'
Base = require '../../require/base'

Base.initialize '.session-menu', '.cart-summary-view'

contactView = new ContactView {el: '.contact-view'}

contactView.render()

$ ->
	Base.onLoad()
	
$(document).foundation()
