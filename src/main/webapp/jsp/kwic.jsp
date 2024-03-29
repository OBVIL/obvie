<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ include file="prelude.jsp"%>
<%@ page import="org.apache.lucene.util.automaton.Automaton"%>
<%@ page import="org.apache.lucene.util.automaton.ByteRunAutomaton"%>
<%@ page import="com.github.oeuvres.alix.lucene.search.Doc"%>
<%@ page import="com.github.oeuvres.alix.lucene.util.WordsAutomatonBuilder"%>
<%
final int hppDefault = 100;
final int hppMax = 1000;
// parameters
int hpp = tools.getInt("hpp", hppDefault);
if (hpp > hppMax || hpp < 1) hpp = hppDefault;
final String q = tools.getString("q", null);
OptionSort sort = (OptionSort) tools.getEnum("sort", OptionSort.score, Cookies.docSort);
boolean expression = tools.getBoolean("expression", false);

int start = tools.getInt("start", 1);
if (start < 1) start = 1;
// global variables
Corpus corpus = (Corpus) session.getAttribute(corpusKey);
long nanos = System.nanoTime();
TopDocs topDocs = getTopDocs(pageContext, alix, corpus, q, sort);
out.println("<!-- get topDocs " + (System.nanoTime() - nanos) / 1000000.0 + "ms\" -->");

final int left = 70;
final int right = 50;
// terms of the query
final String field = TEXT;
String[] terms = alix.tokenize(q, field);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Recherche, <%=alix.props.get("label")%> [Obvie]
</title>
<script src="../static/js/common.js">
    //
</script>
<link href="../static/obvie.css" rel="stylesheet" />
<style>
span.left {
    display: inline-block;
    text-align: right;
    width: <%=Math.round(left * 1.0)%> ex;
    padding-right: 1ex;
}
</style>
</head>
<body class="results">
    <form id="qform">
        <input type="submit"
            style="position: absolute; left: -9999px; width: 1px; height: 1px;"
            tabindex="-1" />
        <%
        if (start > 1 && q != null) {
            int n = Math.max(1, start - hppDefault);
            out.println("<button name=\"next\" type=\"submit\" onclick=\"this.form['start'].value=" + n + "\">◀</button>");
        }
        %>
        <input type="hidden" id="q" name="q"
            value="<%=JspTools.escape(q)%>" autocomplete="off" size="60"
            autofocus="autofocus"
            onfocus="this.setSelectionRange(this.value.length,this.value.length);"
            oninput="this.form['start'].value='';" />
        <script>
            if (self == top) {
                input = document.getElementById("q");
                if (input && input.type == "hidden")
                    input.type = "text";
            }
        </script>
        <select name="sort"
            onchange="this.form['start'].value=''; this.form.submit()"
            title="Ordre">
            <option />
            <%=sort.options()%>
        </select>
        <%
        if (terms == null || terms.length < 2) {
            
        }
        else if (expression) {
            out.println(
            "<button title=\"Cliquer pour dégrouper les locutions\" type=\"submit\" name=\"expression\" value=\"false\">✔ Locutions</button>");
        } else {
            out.println(
            "<button title=\"Cliquer pour grouper les locutions\" type=\"submit\" name=\"expression\" value=\"true\">☐ Locutions</button>");
        }
        if (topDocs != null) {
            long max = topDocs.totalHits.value;
            out.println("<input  name=\"start\" value=\"" + start + "\" autocomplete=\"off\" class=\"start\"/>");
            out.println("<span class=\"hits\"> / " + max + "</span>");
            int n = start + hpp;
            if (n < max)
                out.println("<button name=\"next\" type=\"submit\" onclick=\"this.form['start'].value=" + n + "\">▶</button>");
        }
        %>

    </form>
    <main>
        <%
        if (topDocs != null) {
            
            boolean repetitions = false;
            ByteRunAutomaton automat = null;
            if (terms != null && terms.length > 0) {
                Automaton autoBuilder = WordsAutomatonBuilder.buildFronStrings(terms);
                if (autoBuilder != null) automat = new ByteRunAutomaton(autoBuilder);
                if (terms.length == 1) repetitions = true;
            }
            // get the index in results
            ScoreDoc[] scoreDocs = topDocs.scoreDocs;
            // where to start loop ?
            int i = start - 1; // private index in results start at 0
            int max = scoreDocs.length;
            if (i < 0)
                i = 0;
            else if (i > max)
                i = 0;
            // loop on docs
            int docs = 0;
            final int gap = 3;

            final StringBuilder href = new StringBuilder();
            href.append("doc?");
            if (q != null)
                href.append("q=").append(JspTools.escape(q));
            final int hrefLen = href.length();

            // be careful, if one term, no expression possible, this will loop till the end of corpus
            if (terms == null || terms.length < 2)
                expression = false;

            while (i < max) {
                final int docId = scoreDocs[i].doc;
                i++; // is now a public start
                final Doc doc = new Doc(alix, docId);
                String type = doc.doc().get(Names.ALIX_TYPE);
                // TODO Enenum
                if (type.equals(Names.BOOK)) {
                    continue;
                }
                if (doc.doc().get(TEXT) == null) {
                    continue;
                }
                href.setLength(hrefLen); // reset href
                href.append("&amp;id=").append(doc.id()).append("&amp;start=").append(i);

                // show simple metadata
                if (terms == null || terms.length == 0) {
            out.println("<article class=\"res\">");
            out.println("<header>");
            out.println("<small>" + (i) + ".</small> ");
            out.println("<a href=\"" + href + "\">" + doc.get("bibl") + "</a>");
            out.println("</header>");
            out.println("</article>");
            if (++docs >= hpp)
                break;
                continue;
            }

                List<String[]> lines = doc.kwic(
                    field, 
                    automat, 
                    200, 
                    left, 
                    right, 
                    gap, 
                    expression, 
                    repetitions
                );
                if (lines == null || lines.size() < 1) continue;
                out.println("<article class=\"res\">");
                out.println("<header>");
                out.println("<small>" + (i) + "</small> ");
                out.println("<a href=\"" + href + "\">" + doc.get("bibl") + "</a></header>");

                for (String[] l: lines) {
                    out.println("  <div class=\"line\">");
                    // out.println("    <small class=\"num\">" + ++occ +"</small>");
                    out.println("    <span class=\"left\">" + l[1] + "</span>");
                    out.println("    <a class=\"concline\" href=\""+ href + "#" + l[0] +"\">");
                    // out.println("      <span class=\"pivot\">" + l[2] + "</span>");
                    out.println(l[2]);
                    out.println("</a>");
                    out.println("    <span class=\"right\">" + l[3] + "</span>");
                    out.println("  </div>");
                }
                out.println("</article>");
                if (++docs >= hpp)
            break;
            }

        }
        %>
        <form>
            <%
            if (start > 1 && q != null) {
                int n = Math.max(1, start - hppDefault);
                out.println("<button name=\"prev\" type=\"submit\" onclick=\"this.form['start'].value=" + n + "\">◀</button>");
            }
            %>

            <input type="hidden" id="q" name="q"
                value="<%=JspTools.escUrl(q)%>" />
            <%
            if (topDocs != null) {
                long max = topDocs.totalHits.value;
                out.println("<input  name=\"start\" value=\"" + start + "\" autocomplete=\"off\" class=\"start\"/>");
                out.println("<span class=\"hits\"> / " + max + "</span>");
                int n = start + hpp;
                if (n < max)
                    out.println("<button name=\"next\" type=\"submit\" onclick=\"this.form['start'].value=" + n + "\">▶</button>");
            }
            %>
        </form>
        <a href="#" id="gotop">▲</a>
    </main>
    <%
    out.println("<!-- time\" : \"" + (System.nanoTime() - time) / 1000000.0 + "ms\" -->");
    %>
</body>
</html>
