FROM azul/zulu-openjdk-alpine:8u212

# Default payara ports to expose
EXPOSE 6900 8080

# Configure environment variables
ENV PAYARA_HOME=/opt/payara\
    DEPLOY_DIR=/opt/payara/deployments

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
java.util.logging.ConsoleHandler.level=FINEST\n '\
>> ${PAYARA_HOME}/logging.properties

RUN echo $'set configs.config.server-config.network-config.protocols.protocol.http-listener-1.http.allow-payload-for-undefined-http-methods=true\n '\
>> ${PAYARA_HOME}/postbootcommandfile.txt


# Default command to run
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=90.0", "-jar", "payara-micro.jar"]
CMD ["--deploymentDir", "/opt/payara/deployments", "--logProperties", "/opt/payara/logging.properties", "--postbootcommandfile", "/opt/payara/postbootcommandfile.txt"]

# Download specific
ARG PAYARA_VERSION="5.192"
ENV PAYARA_VERSION="$PAYARA_VERSION"
RUN wget --no-verbose -O ${PAYARA_HOME}/payara-micro.jar http://central.maven.org/maven2/fish/payara/extras/payara-micro/${PAYARA_VERSION}/payara-micro-${PAYARA_VERSION}.jar

