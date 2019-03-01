dependencies:
	(cd themes/falco-fresh && yarn)

serve: dependencies
	hugo server \
		--buildDrafts \
		--buildFuture \
		--disableFastRender

production-build: dependencies
	hugo

preview-build: dependencies
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture
