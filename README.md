# WildFly domain with external Infinispan

The current project aims to show how a remote Infinispan cache is shared among two different Wildfly server groups configured in domain management mode.
Each server group hosts a specific application version.


## Tested using:
- Docker engine version 20.10.17
- Apache Maven version 3.8.6
- Java openjdk version 11.0.2
- macOS Monterey version 12.5

```
# Whole environment setup
./run.sh

# Delete existing cookies
rm -f cookies;

# Invoke AppV1 on Host 1 on ServerGroup1
curl -v -c cookies http://localhost:8080/app/ 

# Expected response:
#
#
#<html>
#   <head>
#      <title>Sessions v1</title>
#   </head>
#
#   <body>
#
#      Current SW Version : V1<br/>
#Session Creation SW Version : V1<br/>
#Last Access SW Version : V1<br/>
#Session Type : NEW<br/>
#Session ID : Gl3OmsTiPLWgSXhp-yl3e2qJH_4DJwmlPzLm1A_x<br/>
#Creation Time : Fri Aug 19 13:51:05 GMT 2022<br/>
#Last Access Time (before current request) : Fri Aug 19 13:51:05 GMT 2022<br/>
#Number of visits : 1<br/>
#
#
#   </body>
#
#</html>


# Invoke AppV2 on Host 2 on ServerGroup2 using the already-set cookie
curl -v -b cookies http://localhost:8181/app/

# Expected response
#
#
#<html>
#   <head>
#      <title>Sessions v2</title>
#   </head>
#
#   <body>
#
#      Current SW Version : V2<br/>
#Session Creation SW Version : V1<br/>
#Last Access SW Version : V1<br/>
#Session Type : PRE EXISTING<br/>
#Session ID : Gl3OmsTiPLWgSXhp-yl3e2qJH_4DJwmlPzLm1A_x<br/>
#Creation Time : Fri Aug 19 13:51:05 GMT 2022<br/>
#Last Access Time (before current request) : Fri Aug 19 13:51:05 GMT 2022<br/>
#Number of visits : 2<br/>
#
#
#   </body>
#
#</html>

```

Play with the given commands as needed.
