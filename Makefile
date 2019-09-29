compile:
	bundle exec middleman build --clean

setup-deploy:
	git worktree add build master

deploy: compile
	cd build && \
	git add --all && \
	git commit -m "Automated commit at `date +'%Y-%m-%d %H:%M:%S'`" && \
	git push origin master && \
	cd -

dev-server:
	bundle exec middleman server
