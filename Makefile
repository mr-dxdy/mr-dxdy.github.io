clean:
	bundle exec jekyll clean

js-compile:
	npm run build

ruby-compile:
	JEKYLL_ENV=production bundle exec jekyll build -d ./build

compile: clean js-compile ruby-compile

setup-deploy:
	git worktree add build master

deploy: compile
	cd build && \
	git add --all && \
	git commit -m "Automated commit at `date +'%Y-%m-%d %H:%M:%S'`" && \
	git push origin master && \
	cd -

dev-server:
	npm run build && ./tools/run.sh
