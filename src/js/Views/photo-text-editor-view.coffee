Backbone = require 'backbone'
PhotoViewer = require './photoviewer'
templates = require './jst'

module.exports = Backbone.View.extend

	events:
		'submit form' : 'saveChanges'

	initialize: (options) ->
		this.template = templates['photo-text-editor-view']
		this.render()
		this.listenTo this.model, 'change:photo', this.photoChanged

	render: ->
		this.$el.html this.template()
		this

	saveChanges: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value	
		this.model.get('photo').save data
		this.$('input[type="submit"]').blur()

	photoChanged: (m) ->
		photo = m.get('photo')	
		json =photo.toJSON()
		text = '';
		for k, v of json
			switch k
				when 'fileName' then this.$('form input[name="fileName"]').val v
				when 'title' then this.$('form input[name="title"]').val v
				when 'description' then this.$('form input[name="description"]').val v
				when 'keywords' then this.$('form input[name="keywords"]').val v
				else text += k + ": " + v + '<br>'

		this.$('.photo-metadata').html text