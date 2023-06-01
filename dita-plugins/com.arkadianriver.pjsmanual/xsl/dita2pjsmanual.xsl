<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opentopic="http://www.idiominc.com/opentopic"
  xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
  xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
  exclude-result-prefixes="#all">

  <xsl:import href="plugin:org.dita.html5:xsl/dita2html5Impl.xsl" />
  <!--
  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl" />
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl" />
  <xsl:import href="plugin:org.dita.base:xsl/common/related-links.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-textonly.xsl"/>
  -->

  <xsl:output method="html"
    include-content-type="no"
    indent="yes"
    doctype-system="about:legacy-compat"
    omit-xml-declaration="yes" />

  <!-- root rule -->
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="*[contains(@class, ' map/map ') and contains(@class, ' bookmap/bookmap ')]">
    <html lang="en">
      <xsl:call-template name="headInfo" />
      <body>
        <xsl:variable name="noticesId">
          <xsl:choose>
            <xsl:when test="/bookmap/opentopic:map/backmatter/notices">
              <xsl:value-of select="/bookmap/opentopic:map/backmatter/notices/@id" />
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="''" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="opentopic:map" mode="frontMatter">
          <xsl:with-param name="noticesId"><xsl:value-of select="$noticesId" /></xsl:with-param>
        </xsl:apply-templates>
        <main xsl:use-attribute-sets="main">
          <xsl:attribute name="id">content</xsl:attribute>
          <xsl:apply-templates select="./*[not(self::opentopic:map)]" mode="addContentToBody" />
        </main>
        <!--
        <xsl:apply-templates select="./*[contains(@class, ' topic/topic ')]" mode="bodyTopics">
          <xsl:with-param name="noticesId"><xsl:value-of select="$noticesId" /></xsl:with-param>
        </xsl:apply-templates>
        -->
      </body>
    </html>
  </xsl:template>

  <xsl:template match="opentopic:map" mode="frontMatter">
    <xsl:param name="noticesId" />
    <header>
      <section id="cover">
        <xsl:choose>
          <xsl:when test="./bookmeta/data[@name='cover-image']">
            <img>
              <xsl:attribute name="href"><xsl:value-of select="./bookmeta/data/image/@href" /></xsl:attribute>
            </img>
          </xsl:when>
          <xsl:otherwise>
            <div class="booklibrary">
              <xsl:value-of
                select="./booktitle/booklibrary" />
            </div>
            <div class="booktitle">
              <xsl:value-of
                select="./booktitle/mainbooktitle" />
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </section>
      <xsl:if
        test="descendant::*[contains(@class, ' bookmap/chapter ')]
      [not(@toc = 'no')]
      [not(@processing-role = 'resource-only')]">
        <section id="table-of-content">
          <h2>
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'Contents'" />
            </xsl:call-template>
          </h2>
          <ol>
            <xsl:apply-templates select="*[contains(@class, ' bookmap/chapter ')]" mode="toc" />
          </ol>
        </section>
      </xsl:if>
      <xsl:if test="$noticesId != ''">
        <xsl:apply-templates
          select="/*[contains(@class, ' bookmap/bookmap ')]/*[contains(@class, ' topic/topic ') and @id=$noticesId]"
          mode="editionNotice" />
      </xsl:if>
    </header>
  </xsl:template>

  <xsl:template
    match="/*[contains(@class, ' bookmap/bookmap ')]/*[contains(@class, ' topic/topic ')]"
    mode="editionNotice">
    <section id="edition-notice">
      <h1>
        <xsl:value-of select="./title" />
      </h1>
      <xsl:apply-templates select="*[contains(@class, ' topic/body ')]" />
    </section>
  </xsl:template>

  <xsl:template match="*" mode="toc">
    <li>
      <a>
        <xsl:attribute name="href"><xsl:value-of select="@href" /></xsl:attribute>
        <xsl:value-of select="./topicmeta/navtitle" />
      </a>
    </li>
  </xsl:template>

  <xsl:template match="*" mode="addContentToBody">
    <xsl:if test="*[contains(@class,' topic/topic ') and not(@oid = 'notices')]">
      <article xsl:use-attribute-sets="article">
        <xsl:attribute name="aria-labelledby">
          <xsl:apply-templates
            select="*[contains(@class,' topic/title ')] |
                                       self::dita/*[1]/*[contains(@class,' topic/title ')]"
            mode="return-aria-label-id" />
        </xsl:attribute>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]"
          mode="out-of-line" />
        <xsl:apply-templates /> <!-- this will include all things within topic; therefore, -->
        <!-- title content will appear here by fall-through -->
        <!-- followed by prolog (but no fall-through is permitted for it) -->
        <!-- followed by body content, again by fall-through in document order -->
        <!-- followed by related links -->
        <!-- followed by child topics by fall-through -->
        <xsl:call-template name="gen-endnotes" />    <!-- include footnote-endnotes -->
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]"
          mode="out-of-line" />
      </article>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="process.note.common-processing">
    <xsl:param name="type" select="@type" />
    <xsl:param name="title">
      <xsl:call-template name="getVariable">
        <xsl:with-param name="id"
          select="concat(upper-case(substring($type, 1, 1)), substring($type, 2))" />
      </xsl:call-template>
    </xsl:param>
    <div>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class"
          select="string-join(($type, concat('note_', $type)), ' ')" />
      </xsl:call-template>
      <xsl:call-template name="setidaname" />
      <!-- Normal flags go before the generated title; revision flags only go on the content. -->
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/prop"
        mode="ditaval-outputflag" />
      <span class="note__title">
        <xsl:copy-of select="$title" />
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'ColonSymbol'" />
        </xsl:call-template>
      </span>
      <xsl:text> </xsl:text>
      <div>
        <xsl:attribute name="class">notebody</xsl:attribute>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/revprop"
          mode="ditaval-outputflag" />
        <xsl:apply-templates />
        <!-- Normal end flags and revision end flags both go out after the content. -->
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]"
          mode="out-of-line" />
      </div>
    </div>
  </xsl:template>

  <!--basic
  child processing-->
  <xsl:template match="*[contains(@class, ' topic/link ')][@role = ('child', 'descendant')]"
    priority="2" name="topic.link_child">
    <li>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class" select="'ulchildlink'" />
      </xsl:call-template>
      <!-- Allow for unknown metadata (future-proofing) -->
      <xsl:apply-templates
        select="*[contains(@class, ' topic/data ') or contains(@class, ' topic/foreign ')]" />
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]"
        mode="out-of-line" />
      <strong>
        <xsl:apply-templates select="." mode="related-links:unordered.child.prefix" />
        <xsl:apply-templates select="." mode="add-link-highlight-at-start" />
        <a>
          <xsl:apply-templates select="." mode="add-linking-attributes" />
          <xsl:apply-templates select="." mode="add-hoverhelp-to-child-links" />

          <!--use
          linktext as linktext if it exists, otherwise use href as linktext-->
          <xsl:choose>
            <xsl:when test="*[contains(@class, ' topic/linktext ')]">
              <xsl:apply-templates select="*[contains(@class, ' topic/linktext ')]" />
            </xsl:when>
            <xsl:otherwise>
              <!--use
              href-->
              <xsl:call-template name="href" />
            </xsl:otherwise>
          </xsl:choose>
        </a>
        <xsl:apply-templates select="." mode="add-link-highlight-at-end" />
      </strong>
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]"
        mode="out-of-line" />
      <br />
      <!--add
      the description on the next line, like a summary-->
      <div>
        <xsl:attribute name="class">childlink-content</xsl:attribute>
        <xsl:apply-templates select="*[contains(@class, ' topic/desc ')]" />
      </div>
    </li>
  </xsl:template>


  <xsl:template name="headInfo">
    <head>
      <title>Document</title>
      <style><![CDATA[
        @media print {
        body {
        font-family: Helvetica, Arial, sans-serif;
        }
        @page {
        size: 297mm 210mm;
        margin: 20mm;
        }
        #cover {
        page: cover;
        }
        #cover img {
        height: 210mm;
        }
        #cover .booktitle, #cover .booklibrary {
        text-align: right;
        margin-right: 40mm;
        font-weight: bold;
        }
        #cover .booklibrary {
        margin-top: 100mm;
        font-size: 40pt;
        }
        #cover .booktitle {
        margin-top: 10mm;
        font-size: 28pt;
        }
        @page cover {
        margin: 0 0;
        width: 297mm;
        }
        #table-of-content {
        page: toc;
        }
        @page toc {
        columns: 1 auto;
        break-before: page;
        break-after: page;
        text-align: left;
        margin: 10mm 40mm 10mm 10mm;
        }
        #table-of-content > h2 {
        font-size: 18;
        font-weight: normal;
        border-bottom: 1px solid black;
        margin-bottom: 48pt;
        }
        #table-of-content > ol {
        counter-reset: list-item;
        margin-right: -60mm;
        font-size: 22pt;
        font-weight: bold;
        text-align: right;
        }
        #table-of-content > ol li {
        margin: 32pt 0 32pt 0;
        list-style-type: none;
        }
        #table-of-content > ol li a {
        text-decoration: none;
        }
        #table-of-content > ol li {
        padding-right: 20mm;
        white-space: pre;
        margin-right: 0;
        }
        #table-of-content > ol li a::after {
        counter-increment: list-item;
        content: counter(list-item);
        white-space: pre;
        background-color: gray;
        color: white;
        margin-left: 60mm;
        padding: 3pt 12pt 3pt 12pt;
        }
        #edition-notice {
        page: frontmatter;
        }
        @page frontmatter {
        columns: 1 auto;
        margin-left: 108mm;
        }
        #edition-notice {
        text-align: justify;
        }
        #edition-notice > h1 {
        text-align: right;
        font-size: 18pt;
        font-weight: normal;
        }
        #content {
        break-before: page;
        counter-reset: chapter;
        }
        nav {
        break-after: page;
        }
        article:not(article[class^=nested]) {
        break-before: page;
        counter-increment: chapter;
        columns: 1;
        }
        article:not(article[class^=nested]) > h1 {
        font-weight: bold;
        font-size: 36pt;
        }
        article > h1::before {
        content: "Chapter " counter(chapter) " | ";
        }
        article:not(article[class^=nested]) > h1::after {
        font-size: 20pt;
        font-weight: normal;
        content: "\0AIn this Chapter:\0A";
        white-space: pre;
        }
        article:not(article[class^=nested]) .related-links {
        margin-left: 20mm;
        font-size: 1.4em;
        }
        article:not(article[class^=nested]) .related-links li {
        display: flex;
        line-height: 2.2rem;
        }
        article:not(article[class^=nested]) .related-links li a {
        order: 1;
        text-decoration: none;
        }
        /*
        article:not(article[class^=nested]) .related-links li .folio {
        order: 3;
        }
        */
        article:not(article[class^=nested]) .related-links li strong {
        text-weight: normal;
        color: red;
        }
        article:not(article[class^=nested]) .related-links li .childlink-content {
        display: none;
        }
        article:not(article[class^=nested]) .related-links li strong::after {
        target-counter(attr(href), page);
        order: 3;
        }
        article:not(article[class^=nested]) .related-links li::after {
        background-image: radial-gradient(
        circle,
        currentcolor 1px,
        transparent 1.5px
        );
        background-position: bottom;
        background-size: 1ex 4.5px;
        background-repeat: space no-repeat;
        content: "";
        flex-grow: 1;
        height: 1em;
        order: 2;
        }
        article.nested1 {
        columns: 3 auto;
        column-gap: 5mm;
        }
        .warning {
        display: flex;
        flex-direction: column;
        }
        .warning > span[class$=title] {
        border: 1px solid black;
        display: block;
        padding: 3pt 6pt 3pt 6pt;
        font-weight: bold;
        }
        .warning > span[class$=title]::before {
        content: url("../hello-truck-world/docsrc/images/warning.gif") " ";
        vertical-align: middle;
        }
        .notebody {
        border: 1px solid black;
        padding: 3pt 6pt 3pt 6pt;
        }
        }]]>
      </style>
    </head>
  </xsl:template>


</xsl:stylesheet>