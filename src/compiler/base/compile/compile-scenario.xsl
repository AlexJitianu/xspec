<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Utils for compiling x:scenario
   -->

   <xsl:template name="x:diag-compiling-scenario" as="empty-sequence()">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="level" as="xs:string" select="'ERROR'" />
      <xsl:param name="message" as="xs:string" />

      <xsl:message terminate="{$level eq 'ERROR'}"
         select="x:prefix-diag-message($level, ., $message)" />
   </xsl:template>

   <!-- Checks max x:param/@position. The caller of this template must ensure that the current
      scenario (not its descendant scenario) is going to run SUT. -->
   <xsl:template name="x:check-param-max-position" as="empty-sequence()">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />

      <xsl:variable name="max-param-position" as="xs:integer?"
         select="max($call/x:param ! xs:integer(@position))" />
      <xsl:if test="$max-param-position gt count($call/x:param)">
         <xsl:call-template name="x:diag-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Too large parameter position, {$max-param-position}, used in {name($call)}.</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <!-- Returns a text node of the function call expression. The names of the function and the
      parameter variables are URIQualifiedName. -->
   <xsl:function name="x:function-call-text" as="text()">
      <xsl:param name="call" as="element(x:call)" />

      <!-- xsl:for-each is not for iteration but for simplifying XPath -->
      <xsl:for-each select="$call">
         <xsl:variable name="function-uqname" as="xs:string">
            <xsl:choose>
               <xsl:when test="contains(@function, ':')">
                  <xsl:sequence select="x:UQName-from-EQName-ignoring-default-ns(@function, .)" />
               </xsl:when>
               <xsl:otherwise>
                  <!-- Function name without prefix is not Q{}local but fn:local -->
                  <xsl:sequence select="@function/string()" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

         <xsl:value-of>
            <xsl:text expand-text="yes">{$function-uqname}(</xsl:text>
            <xsl:for-each select="x:param">
               <xsl:sort select="xs:integer(@position)" />

               <xsl:text expand-text="yes">${x:variable-UQName(.)}</xsl:text>
               <xsl:if test="position() ne last()">
                  <xsl:text>, </xsl:text>
               </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
         </xsl:value-of>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>