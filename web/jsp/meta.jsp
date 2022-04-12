<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ include file="prelude.jsp"%>
<%@ page import="org.apache.lucene.search.BooleanClause"%>
<%@ page import="alix.lucene.analysis.MetaAnalyzer"%>
<%@ page import="alix.lucene.search.Doc"%>
<%@ page import="alix.lucene.search.Marker"%>
<%@ page import="alix.util.Top"%>
<%!
final static Analyzer ANAMET = new MetaAnalyzer();
final static HashSet<String> DOC_SHORT = new HashSet<String>(Arrays.asList(new String[]{Names.ALIX_ID, Names.ALIX_BOOKID, "bibl"}));

private Query mlt(Doc doc, String field) throws IOException, NoSuchFieldException
{
    final int mltLimit = 50;
    Query mlt = null;
    BooleanQuery.Builder qBuilder = new BooleanQuery.Builder();
    FormEnum forms = doc.forms(field, OptionDistrib.g.scorer(), OptionCat.STRONG.tags());
    forms.sort(FormEnum.Order.score, mltLimit, false);
    forms.reset();
    while (forms.hasNext()) {
        forms.next();
        String form = forms.form();
        if (form.trim().isEmpty()) continue; // seen but should not
        Query tq = new TermQuery(new Term(field, form));
        qBuilder.add(tq, BooleanClause.Occur.SHOULD);
    }
    mlt = qBuilder.build();
    return mlt;
}


/**
 * Build a query fron page params, a selected  corpus a reference 
 */
private Query query(final JspTools tools, final Corpus corpus, final Doc refDoc)
        throws IOException, NoSuchFieldException {
    Query query = null;
    String refType = tools.getString("reftype", null);
    String q = tools.getString("q", null);
    if (refDoc != null) {
        query = mlt(refDoc, TEXT);
    } 
    else if (q != null) {
        String lowbibl = q.toLowerCase();
        query = Alix.query("bibl", lowbibl, ANAMET, Occur.MUST);
    }
    // restrict to corpus
    if (corpus != null) {
        query = corpusQuery(corpus, query);
    }
    // meta, restric document type
    else if (query != null && q != null) {
        query = new BooleanQuery.Builder().add(QUERY_CHAPTER, Occur.FILTER).add(query, Occur.MUST).build();
    }
    // no queries by parameter
    else if (query == null) {
        query = QUERY_CHAPTER;
    }
    return query;
}

private String results(final JspTools tools, final Corpus corpus, final Doc refDoc, final IndexSearcher searcher)
        throws IOException, NoSuchFieldException {
    StringBuilder sb = new StringBuilder();

    Query query = query(tools, corpus, refDoc);
    if (query == null)
        return "";
    TopDocs results = null;
    int fromDoc = tools.getInt("fromdoc", -1);
    float fromScore = tools.getFloat("fromscore", 0);
    int hpp = 100; // default results in full html page
    int parhpp = tools.getInt("hpp", -1);
    if (parhpp > 0)
        hpp = parhpp;
    hpp = Math.min(hpp, 1000);

    if (fromDoc > -1) {
        ScoreDoc from = new ScoreDoc(fromDoc, fromScore);
        results = searcher.searchAfter(from, query, hpp);
    } else {
        results = searcher.search(query, hpp);
    }

    if (results == null)
        return "";
    if (results.totalHits.value == 0)
        return ""; // no results
    String paging = "";
    if (fromDoc > 0) {
        paging = "&amp;fromdoc=" + fromDoc + "&amp;fromscore=" + fromScore;
    }

    String q = tools.getString("q", null);
    String refType = tools.getString("reftype", null);
    String back = "";
    // a query to hilite in records
    if (q != null) {
        back += "&amp;q=" + q;
    } else if (refDoc != null) {
        back += "&amp;refid=" + refDoc.id();
        if (refType != null)
            back += "&amp;reftype" + refType;
    }

    Marker marker = null;
    if (q != null)
        marker = new Marker(ANAMET, q);

    long totalHits = results.totalHits.value;
    ScoreDoc[] hits = results.scoreDocs;
    int docId = 0;
    float score = 0;
    for (int i = 0, len = hits.length; i < len; i++) {
        docId = hits[i].doc;
        score = hits[i].score;
        // out.append("<li>");
        Document doc = searcher.doc(docId, DOC_SHORT);

        String text = doc.get("bibl");
        // fast hack because of links in links
        text = text.replaceAll("<(/?)a([ >])", "<$1span$2");
        if (marker != null) {
            sb.append("<a class=\"bibl\" href=\"compdoc.jsp?id=" + doc.get(Names.ALIX_ID) + paging + back + "\">");
            sb.append(marker.mark(text));
            sb.append("</a>\n");
        } else {
            sb.append("<a class=\"bibl\" href=\"compdoc.jsp?id=" + doc.get(Names.ALIX_ID) + paging + back + "\">");
            sb.append(text);
            sb.append("</a>\n");
        }
        // out.append("</li>\n");
    }
    if (hits.length < totalHits) {
        if (parhpp > 0)
            back += "&amp;hpp=" + parhpp;
        sb.append("<a  class=\"more\" href=\"?fromscore=" + score + "&amp;fromdoc=" + docId + back + "\">⮟</a>\n");
    }
    return sb.toString();
}%>
<%
// page parameters
String refId = tools.getString("refid", null);
int refDocId = tools.getInt("refdocid", -1);
String refType = tools.getString("reftype", null);
String q = tools.getString("q", null);
String format = tools.getString("format", null);
if (format == null)
    format = (String) request.getAttribute(Dispatch.EXT);

// global varaiables
Corpus corpus = (Corpus) session.getAttribute(corpusKey);

// Is there a good reference doc requested ?
Doc refDoc = null;
try {
    if (refId != null)
        refDoc = new Doc(alix, refId, DOC_SHORT);
    else if (refDocId >= 0) {
        refDoc = new Doc(alix, refDocId, DOC_SHORT);
        refId = refDoc.id();
    }
} catch (IllegalArgumentException e) {
    refId = null;
} // unknown id

// parameter 
if (OptionMime.htf.name().equals(format)) {
    out.println(results(tools, corpus, refDoc, searcher));
} 
else {
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Recherche bibliographique, <%=(corpus != null) ? JspTools.escape(corpus.name()) + ", " : ""%><%=alix.props.get("label")%>
    [Obvie]
</title>
<script src="../static/js/common.js">
    //
</script>
<link href="../static/obvie.css" rel="stylesheet" />
</head>
<body class="results">
    <header>
        <%
        if (refDoc != null) {
            out.println("<h1>Textes similaires</h1>");
            out.println("<a href=\"?\" class=\"delete\">🞬</a>");
            out.println("<b>Textes similaires à :</b>");
            out.println(refDoc.doc().get("bibl"));
        } else {
            out.println("<h1>Rechercher un texte par ses métadonnées</h1>");
        }
        if (corpus != null) {
            out.println("<p>Dans votre corpus : " + "<b>" + corpus.name() + "</b>" + "</p>");
        }
        %>
    </header>
    <form>
        <%
        if (refDoc != null) {
            out.println("<input type=\"hidden\" name=\"refid\" value=\"" + refDoc.id() + "\"/>");
        } else {
            out.print(
            "<input size=\"50\" type=\"text\" id=\"q\" onfocus=\"var len = this.value.length * 2; this.setSelectionRange(len, len); \" autofocus=\"true\"");
            out.println(" spellcheck=\"false\" autocomplete=\"off\" name=\"q\" value=\"" + JspTools.escape(q) + "\"/>");
            // out.println("<br/>" + query);
        }
        %>
    </form>
    <p />
    <main>
        <nav id="chapters">
            <%=results(tools, corpus, refDoc, searcher)%>
        </nav>
    </main>
    <a href="#" id="gotop">▲</a>
    <%
    out.println("<!-- time\" : \"" + (System.nanoTime() - time) / 1000000.0 + "ms\" -->");
    %>
    <script src="../static/js/list.js">//</script>
</body>
</html>
<%
}
%>