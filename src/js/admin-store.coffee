$ = require 'jquery'
require 'foundation'
AdminStoreView = require('../../require/admin-store-view')
Session = require('../../require/session')
Settings = require('../../require/settings')
AdminSettingsView = require('../../require/admin-settings-view')

adminStoreView = new AdminStoreView {el: '.admin-store-view'}

session = new Session()
settings = new Settings null, {session: session}
adminSettingsView = new AdminSettingsView {el: '#admin-editSettings', model:settings}

adminStoreView.render()
adminSettingsView.render()

session.fetch()

$ ->
	$(document).foundation()
