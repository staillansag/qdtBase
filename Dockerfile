# We a base product image built using the SAG installer, which comprises the CloudStreams server and the JDBC adapter
# Use the folowing command to rebuild it, where installer.bin is the Linux installer available in Empower
# sh installer.bin create container-image --name <your-image-name> --release 10.15 --accept-license --products MSC,wst,jdbcAdapter --admin-password manage --username $EMPOWER_USERNAME --password $EMPOWER_PASSWORD
FROM staillansag/webmethods-microservicesruntime:10.15.0.9-wst-jdbc

# Install the wpm tool. With webMethods 11, wpm will automatically be included and this step will no longer be needed
ADD --chown=sagadmin:sagadmin wpm /opt/softwareag/wpm
RUN chmod u+x /opt/softwareag/wpm/bin/wpm.sh
ENV PATH=/opt/softwareag/wpm/bin:$PATH

# wpm needs a Github token to fetch the qdtFramework, we receive it as a build argument and store it in an environment variable
ARG GIT_TOKEN
ENV GIT_TOKEN=$GIT_TOKEN

# Install the CloudStreams Salesforce adapter from a local folder (this connector is not yet available in packages.softwareag.com)
ADD --chown=sagadmin:sagadmin WmSalesforceRESTProvider /opt/softwareag/IntegrationServer/packages/WmSalesforceRESTProvider

# We also need to add another repo, which contains our framework. We use the webMethods package manager (wpm) to do so
RUN /opt/softwareag/wpm/bin/wpm.sh install -u staillansag -p $GIT_TOKEN -r https://github.com/staillansag -d /opt/softwareag/IntegrationServer qdtFramework

# Download the Postgres JDBC driver and place it in the WmJDBCAdapter/code/jars folder
WORKDIR /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars
RUN curl -O https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
WORKDIR /
