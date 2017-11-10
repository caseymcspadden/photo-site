$ = require 'jquery'
require 'foundation'
Base = require '../../require/base'
AuthorizeView =  require('../../require/authorize-view')

Base.initialize '.session-menu', '.cart-summary-view'

authorizeView = new AuthorizeView {el: '.authorize-view', model: Base.session}

$ ->
	Base.onLoad()

$(document).foundation()
