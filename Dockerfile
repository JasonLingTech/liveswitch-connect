FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /app

COPY FM.LiveSwitch.Connect.sln FM.LiveSwitch.Connect.sln
COPY GitVersion.yml GitVersion.yml
COPY src src
COPY .git .git

RUN dotnet restore
RUN dotnet publish src/FM.LiveSwitch.Connect/FM.LiveSwitch.Connect.csproj -c Release -o lib
RUN rm FM.LiveSwitch.Connect.sln
RUN rm GitVersion.yml
RUN rm -rf src
RUN rm -rf .git

FROM mcr.microsoft.com/dotnet/runtime:3.1
WORKDIR /app
COPY --from=build /app/lib .

COPY ls-scripts/run-fake.sh /app/run-fake.sh
COPY ls-scripts/run-shell.sh /app/run-shell.sh
COPY ls-scripts/run-log.sh /app/run-log.sh
COPY ls-scripts/run-render.sh /app/run-render.sh
COPY ls-scripts/run-wrapper.sh /app/run-wrapper.sh
COPY ls-scripts/run-shutdown.sh /app/run-shutdown.sh

RUN chmod +x /app/run-wrapper.sh
RUN chmod +x /app/run-render.sh
RUN chmod +x /app/run-shell.sh
RUN chmod +x /app/run-log.sh
RUN chmod +x /app/run-shutdown.sh

ARG IMAGE_TIMEZONE
ARG LS_MEDIA_GATEWAY_URL
ARG LS_MEDIA_GATEWAY_SECRET
ARG LS_API_KEY
ARG LS_APPLICATION_ID
ARG LS_CHANNEL_ID

#https://demo-prod.liveswitch.fm/#gatewayurl=https://cloud.liveswitch.io&sharedsecret=0070c9c582894ef7969986ba228399c527201d910ed9451eb8b45097194ad688&application=62c0809a-5671-426f-94a5-8edbdd1fe962&channel=rusty-test-channel
ENV LS_HOME_URL="https://demo-prod.liveswitch.fm/#"
ENV ENV_TIMEZONE=${IMAGE_TIMEZONE}
ENV ENV_LS_MEDIA_GATEWAY_URL=${LS_MEDIA_GATEWAY_URL}
ENV ENV_LS_MEDIA_GATEWAY_SECRET=${LS_MEDIA_GATEWAY_SECRET}
ENV ENV_LS_API_KEY=${LS_API_KEY}
ENV ENV_LS_APPLICATION_ID=${LS_APPLICATION_ID}
ENV ENV_LS_CHANNEL_ID=${LS_CHANNEL_ID}

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends ffmpeg=7:4.* && \
    apt-get install -y procps && \
    apt-get install -y vim && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/app/run-wrapper.sh"]
#CMD ["/app/wrapper.sh"]
