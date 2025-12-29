# use the base VNC image
FROM git.merith.xyz/gns3/base-vnc:latest
## START setting your image here

# RUN apk add --no-cache firefox-esr

## STOP setting up your image here
# DO NOT REMOVE AND DO NOT ADD AN "ENTRYPOINT" COMMAND
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh