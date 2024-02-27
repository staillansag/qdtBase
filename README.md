#   Build of the MSR base image

There are several methods to build a base image:
-   using the product images provided at https://containers.softwareag.com, combined with the packages registry https://packages.softwareag.com and the webMethods Package Manager (wpm)
-   using the SAG installer
-   using sag-unattended-installations (https://github.com/SoftwareAG/sag-unattended-installations)
  
We will use the first option, the one officially recommended by SAG.  

There are a few prerequisites:
-   You need to get your docker login credentials from https://containers.softwareag.com
-   You then need to use these credentials to login in your favorite shell: `docker login -u ${USER_NAME} -p ${PASSWORD} sagcr.azurecr.io`
-   You also need to get a wpm token from https://packages.softwareag.com
You can login to both https://containers.softwareag.com and https://packages.softwareag.com using your Empower credentials.


Once you've done your docker login and you've retrieved your wpm token, you can use the following Dockerfile to build your base image:
```
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
```  

To perform the build, use the following command
```
docker build --build-arg WPM_TOKEN=<your-wpm-token> -t <your-image-name> .
```

You can then push this image to your own Docker image registry, if you wish.  

You usually don't rebuild your bases images every week (unlike the microservices images which can change very often.) Since SAG publishes new product images (which fixes and improvements) on a monthly basis, this process of creating a new base image version should be managed with the same pace. Just ensure you version these base images accordingly - having a base image version that references the SAG product image version that was used to build it might be a good practice.