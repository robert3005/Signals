all: dir | js
	cp dev/build/*.js dev/webroot/js

dir:
	mkdir -p dev/build/templates

js-renderer:
	node_modules/.bin/coffee -cbj dev/build/renderer.js dev/client/renderer/*

js-templates:
	find dev/client/templates -name *.handlebars -print0 | xargs -I {} -0 sh -c 'f=`basename {}`; handlebars {} -f dev/build/templates/`basename {}`.js'
	cat dev/build/templates/* > dev/webroot/js/templates.js

js-views:
	find dev/client/views -name *.coffee -exec node_modules/.bin/coffee -cj dev/build/views.js {} +

js-models:
	find dev/client/models -name *.coffee -exec node_modules/.bin/coffee -cj dev/build/models.js {} +

js-collections:
	find dev/client/collections -name *.coffee -exec node_modules/.bin/coffee -cj dev/build/collections.js {} +

js: js-templates js-views js-models js-collections js-renderer
	find dev/client -maxdepth 1 -name *.coffee -exec node_modules/.bin/coffee -cj dev/build/signals.js {} +
