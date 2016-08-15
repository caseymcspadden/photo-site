$ = require 'jquery'
require 'foundation'
Folder = require('../../require/folder')
FolderView = require('../../require/folder-view')
Base = require '../../require/base'

Base.initialize '.session-menu', '.cart-summary-view'

folderView = new FolderView {model: new Folder, el: '.folder-view'}
folderView.render()

$ ->
	Base.onLoad()

$(document).foundation()
