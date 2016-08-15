$ = require 'jquery'
require 'foundation'
Base = require '../../require/base'

Base.initialize '.session-menu', '.cart-summary-view'

$ ->
	Base.onLoad()
	
$(document).foundation()