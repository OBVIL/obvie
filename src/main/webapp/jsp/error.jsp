<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="fr.sorbonne_universite.obtic.obvie.Rooter" %>
<%
String baseHref = request.getContextPath() + '/';
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
  <head>
    <meta charset="UTF-8"/>
    <link href="<%=baseHref%>static/obvie.css" rel="stylesheet"/>
    <%
String redirect = (String)request.getAttribute(Rooter.REDIRECT);
if (redirect != null) {
  out.println("<meta http-equiv=\"refresh\" content=\"0; URL="+redirect+"\">");
}
    %>
    <title>Error</title>
  </head>
  <body class="document">
    <article class="chapter">
    <%=request.getAttribute(Rooter.MESSAGE) %>
    </article>
  </body>
</html>

