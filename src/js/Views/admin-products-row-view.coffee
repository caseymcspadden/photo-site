BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	tagName: 'tr'

	events:
		'click .isactive' : 'isActiveClicked'

	initialize: (options) ->
		this.template = templates['admin-products-row-view']

	isActiveClicked: (e) ->
		this.model.set 'active' , !this.model.get('active')
		this.model.save()

	render: ->
		this.$el.html this.template(this.model.toJSON())
		this
