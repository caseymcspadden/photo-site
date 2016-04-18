Backbone = require 'backbone'
FolderContainer = require './foldercontainer'

module.exports = Backbone.Collection.extend
	model: FolderContainer

	comparator: 'position'

