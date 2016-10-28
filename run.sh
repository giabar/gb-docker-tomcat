#!/bin/bash
ADMIN_USER=${ADMIN_USER:-myadmin}
ADMIN_PASS=${ADMIN_PASS:-yourtomcat}
MAX_UPLOAD_SIZE=${MAX_UPLOAD_SIZE:-52428800}
CATALINA_OPTS=${CATALINA_OPTS:-"-Xms128m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=256m -Djava.security.egd=file:/dev/./urandom"}

export CATALINA_OPTS="${CATALINA_OPTS}"

cat << EOF > /usr/local/tomcat/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <role rolename="manager-gui"/>
  <user username="myadmin" password="yourtomcat" roles="manager-gui,admin-gui,admin-script"/>
</tomcat-users>
EOF

cat << EOF > /usr/local/tomcat/webapps/manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="^.*$" />
</Context>
EOF

cat << EOF > /usr/local/tomcat/webapps/host-manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="^.*$" />
</Context>
EOF

if [ -f "/usr/local/tomcat/webapps/manager/WEB-INF/web.xml" ]
then
        sed -i "s#.*max-file-size.*#\t<max-file-size>${MAX_UPLOAD_SIZE}</max-file-size>#g" /usr/local/tomcat/webapps/manager/WEB-INF/web.xml
        sed -i "s#.*max-request-size.*#\t<max-request-size>${MAX_UPLOAD_SIZE}</max-request-size>#g" /usr/local/tomcat/webapps/manager/WEB-INF/web.xml
fi

exec /usr/local/tomcat/bin/catalina.sh run
