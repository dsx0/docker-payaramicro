FROM azul/zulu-openjdk-alpine:11.0.8-jre-headless

# Default payara ports to expose
EXPOSE 6900 8080

# Configure environment variables
ENV PAYARA_HOME=/opt/payara\
    DEPLOY_DIR=/opt/payara/deployments

RUN apk add --update ttf-dejavu

# Create and set the Payara user and working directory owned by the new user
RUN addgroup payara && \
    adduser -D -h ${PAYARA_HOME} -H -s /bin/bash payara -G payara && \
    echo payara:payara | chpasswd && \
    mkdir -p ${DEPLOY_DIR} && \
    chown -R payara:payara ${PAYARA_HOME}
USER payara
WORKDIR ${PAYARA_HOME}

RUN echo $'handlers=java.util.logging.ConsoleHandler\n\
java.util.logging.ConsoleHandler.formatter=fish.payara.enterprise.server.logging.JSONLogFormatter\n\
java.util.logging.ConsoleHandler.level=FINEST\n\n '\
>> ${PAYARA_HOME}/logging.properties

RUN echo $'set configs.config.server-config.network-config.protocols.protocol.http-listener.http.allow-payload-for-undefined-http-methods=true\n '\
>> ${PAYARA_HOME}/postbootcommandfile.txt

#maybe max postsize in future (-1 is unlimited):
#... set configs.config.server-config.network-config.protocols.protocol.http-listener-1.http.max-form-post-size-bytes=-1

# Default command to run
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=90.0", "-jar", "payara-micro.jar"]
CMD ["--deploymentDir", "/opt/payara/deployments", "--logProperties", "/opt/payara/logging.properties", "--postbootcommandfile", "/opt/payara/postbootcommandfile.txt", "--disablephonehome", "--minhttpthreads", "10", "--maxhttpthreads", "200", "--nocluster"]

# Download specific
ARG PAYARA_VERSION="5.201"
ENV PAYARA_VERSION="$PAYARA_VERSION"
#old url
#RUN wget --no-verbose -O ${PAYARA_HOME}/payara-micro.jar http://central.maven.org/maven2/fish/payara/extras/payara-micro/${PAYARA_VERSION}/payara-micro-${PAYARA_VERSION}.jar
#new url
RUN wget --no-verbose -O ${PAYARA_HOME}/payara-micro.jar https://repo1.maven.org/maven2/fish/payara/extras/payara-micro/${PAYARA_VERSION}/payara-micro-${PAYARA_VERSION}.jar

