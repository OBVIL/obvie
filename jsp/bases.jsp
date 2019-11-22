<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Properties" %>
<%@ page import="obvue.Dispatch" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
  <head>
    <meta charset="UTF-8">
    <title>Obvue, bases à chercher</title>
    <link href="static/obvue.css" rel="stylesheet"/>
  </head>
  <body>
    <article class="chapter">
      <h1>Obvue, bases à chercher sur ce serveur.</h1>
      <ul>
      <%
  HashMap<String, Properties> baseList = (HashMap<String, Properties>)request.getAttribute(Dispatch.BASE_LIST);
  int size = baseList.size();
  String[] keys = new String[size];
  keys = baseList.keySet().toArray(keys);
  Arrays.sort(keys);
  for (int i = 0; i < size; i++) {
    Properties props = baseList.get(keys[i]);
    String title = props.getProperty("title", null);
    if (title == null) title = props.getProperty("name", null);
    if (title == null) title =  keys[i];
    out.println("<li><a href=\""+keys[i]+"/\">"+title+"</li>");
  }
      %>
      </ul>
    </article>
  </body>
</html>

