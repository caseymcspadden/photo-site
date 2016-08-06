$ = require 'jquery'
require 'foundation'
#Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
Folder = require('../../require/folder')
FolderView = require('../../require/folder-view')
CartSummaryView = require('../../require/cart-summary-view')
CartItems = require('../../require/cartitems')
config = require('../../require/config')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView {el: '.session-menu', model: session}
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}

$('body').append loginView.render().el

folderView = new FolderView {model: new Folder, el: '.folder-view'}

folderView.render()

$ ->
	session.fetch()
	cartItems.fetch {reset: true}

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
