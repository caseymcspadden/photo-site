BaseView = require './base-view'
templates = require './jst'
config = require './config'
ChooseView = require './choose-view'

module.exports = BaseView.extend

	events:
		'click .select-all' : 'selectAllClicked'		

	initialize: (options) ->
		this.template = templates['choose-photos-view']
		this.listenTo(this.collection,'reset',this.addAll) if this.collection

	render: ->
		this.$el.html this.template()

	selectAllClicked: (e) ->
		this.collection.each (photo) ->
			photo.set 'chosen' , e.target.checked

	addOne: (photo) ->
		chooseView = new ChooseView {model: photo}
		this.$('.choose-photos').append chooseView.render().el

	addAll: ->
		this.collection.each this.addOne, this
