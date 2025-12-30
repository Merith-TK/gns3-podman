tar-caddyserver:
	cd ./example/caddyserver.archive && tar -czf ../caddyserver.tar.gz .
	cd ./example/caddyserver.archive && tar -cf ../caddyserver.tar .

.PHONY: tar-caddyserver