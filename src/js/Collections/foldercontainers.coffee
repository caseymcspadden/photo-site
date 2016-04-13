Backbone = require 'backbone'
FolderContainer = require './foldercontainer'
config = require './config'

module.exports = Backbone.Collection.extend
	model: FolderContainer

	comparator: 'position'

