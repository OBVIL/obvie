<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.nio.file.Path"%>
<%@ page import="java.util.Map"%>
<%@ page import="fr.sorbonne_universite.obtic.obvie.Rooter"%>
<%@ page import="com.github.oeuvres.alix.lucene.Alix"%>
<%@ page import="com.github.oeuvres.alix.lucene.Alix.FSDirectoryType"%>
<%@ page import="com.github.oeuvres.alix.lucene.analysis.FlagFindFilterTest"%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
<meta charset="UTF-8" />
<link href="../static/obvie.css" rel="stylesheet" />
<title>Status, Obvie</title>
</head>
<body>
<body class="document">
    <article class="chapter">
        <h1>Obvie, status</h1>
        <ul>
            <li>ext=<%=request.getAttribute(Rooter.EXT)%></li>
            <li>pathinfo=<%=request.getAttribute(Rooter.PATHINFO)%></li>
            <li>baseList=<%=request.getAttribute(Rooter.BASE_LIST)%></li>
            <li>base=<%=request.getAttribute(Rooter.BASE)%></li>
            <li>props=<%=request.getAttribute(Rooter.PROPS)%></li>
            <li>path=<%=request.getAttribute("path")%></li>
            <li>RequestUri=<%=request.getRequestURI()%></li>
            <li>ContexPath=<%=request.getContextPath()%></li>
            <%
            for (String s : new String[] { AsyncContext.ASYNC_CONTEXT_PATH, AsyncContext.ASYNC_PATH_INFO,
                        AsyncContext.ASYNC_REQUEST_URI, AsyncContext.ASYNC_SERVLET_PATH, RequestDispatcher.FORWARD_CONTEXT_PATH,
                        RequestDispatcher.FORWARD_PATH_INFO, RequestDispatcher.FORWARD_QUERY_STRING,
                        RequestDispatcher.FORWARD_REQUEST_URI, RequestDispatcher.FORWARD_SERVLET_PATH }) {
                    out.println("<li>" + s + "=" + request.getAttribute(s) + "</li>");
                }
                try {
                    // final String baseDir = (String)request.getAttribute(Dispatch.BASE_DIR);
                    final String base = (String) request.getAttribute(Rooter.BASE);
                    final Alix alix = Alix.instance(base);
                    out.println("<li><pre>" + alix + "</pre></li>");
                } catch (Exception e) {
                    out.println("<li>" + e + "</li>");
                }
            %>
        </ul>
        <h5>Paramètres</h5>
        <dl>
            <%
            Map<String, String[]> parameters = request.getParameterMap();
            for (String key : parameters.keySet()) {
                out.println("<dt>" + key + "</dt>");
                String[] values = parameters.get(key);
                if (values == null)
                    ;
                else if (values.length < 1)
                    ;
                else {
                    out.println("<dd>");
                    boolean first = true;
                    for (String v : values) {
                if (first)
                    first = false;
                else
                    out.print("<br/>");
                out.println(v);
                    }
                    out.println("</dd>");
                }
            }
            %>
        
    </article>
</body>
</html>

