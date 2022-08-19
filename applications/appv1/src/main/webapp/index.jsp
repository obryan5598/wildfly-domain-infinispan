<html>
   <head>
      <title>Sessions v1</title>
   </head>
   
   <body>
      <%@ page import = "java.io.*,java.util.*" %>
      <%
	 String currentVersion = "V1";
	 String lastAccessVersion = "";
	 String sessionCreationVersion = "";
	 String sessionType = "";
	 Integer visitCount = new Integer(0);
	 Date createTime = new Date(session.getCreationTime());
	 Date lastAccessTime = new Date(session.getLastAccessedTime());

         if (session.isNew() ){
      		sessionType = "NEW";
		lastAccessVersion = currentVersion;
	        session.setAttribute("lastAccessVersion", currentVersion);
	        session.setAttribute("sessionCreationVersion", currentVersion);
	        session.setAttribute("visits", visitCount);

	} else {
      		sessionType = "PRE EXISTING";
	        lastAccessVersion = (String) session.getAttribute("lastAccessVersion");
		session.setAttribute("lastAccessVersion", currentVersion);
	}        

	visitCount = (Integer)session.getAttribute("visits");
	visitCount = visitCount + 1;
   	session.setAttribute("visits",  visitCount);
	

	out.println("Current SW Version : " + currentVersion + "<br/>");

	out.println("Session Creation SW Version : " + session.getAttribute("sessionCreationVersion") + "<br/>");

	out.println("Last Access SW Version : " + lastAccessVersion + "<br/>");

	out.println("Session Type : " + sessionType + "<br/>");

	out.println("Session ID : " + session.getId() + "<br/>");

	out.println("Creation Time : " + createTime + "<br/>");

	out.println("Last Access Time (before current request) : " + lastAccessTime + "<br/>");

	out.println("Number of visits : " + visitCount + "<br/>");

      %>
      
   </body>
   
</html>
