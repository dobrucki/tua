FROM jboss/wildfly
RUN /opt/jboss/wildfly/bin/add-user.sh admin admin --silent
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
COPY ./mysql-connector-java-8.0.22.jar /opt/jboss/wildfly/modules/system/layers/base/com/mysql/main/
COPY ./module.xml /opt/jboss/wildfly/modules/system/layers/base/com/mysql/main/
COPY ./standalone.xml /opt/jboss/wildfly/standalone/configuration/standalone.xml
COPY ./app.properties /opt/jboss/wildfly/standalone/configuration/
COPY ./ssbd06-Kv1.0.0.war /opt/jboss/wildfly/standalone/deployments/
