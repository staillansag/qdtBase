# Build using an explicit product image version. New versions are published on a monthly basis.
FROM sagcr.azurecr.io/webmethods-microservicesruntime:10.15.0.9

# Install the wpm tool. With webMethods 11, wpm will automatically be included and this step will no longer be needed
ADD --chown=sagadmin:sagadmin wpm /opt/softwareag/wpm
RUN chmod u+x /opt/softwareag/wpm/bin/wpm.sh
ENV PATH=/opt/softwareag/wpm/bin:$PATH

# Store the wpm token in an environment variable, so that we can use it in the subsequent steps
ARG WPM_TOKEN
ENV WPM_TOKEN=$WPM_TOKEN

# install the WmJDBCAdapter package using wpm - this is where the wpm token is used
WORKDIR /opt/softwareag/wpm
RUN /opt/softwareag/wpm/bin/wpm.sh install -ws https://packages.softwareag.com -wr softwareag -j $WPM_TOKEN -d /opt/softwareag/IntegrationServer WmJDBCAdapter
WORKDIR /

# Download the Postgres JDBC driver and place it in the WmJDBCAdapter/code/jars folder
WORKDIR /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars
RUN curl -O https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
WORKDIR /