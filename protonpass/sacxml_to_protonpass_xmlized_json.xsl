<?xml version="1.0" ?>
<xsl:stylesheet
        version="3.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:uuid="java.util.UUID"
        xsi:exclude-result-prefixes="uuid">
    <!--xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">-->
    <!--    xmlns:uuid="java.util.UUID xsi:noSchemaLocation"-->

    <xsl:output method="xml" encoding="UTF-8" indent="yes" xml:space="preserve"/>

    <xsl:param name="userId"/>
    <xsl:param name="vaultId"/>
    <xsl:param name="vaultDesc"/>
    <xsl:param name="vaultColor"/>
    <xsl:param name="vaultIcon"/>

    <xsl:variable name="typeMap">
        <types>
            <type id="string">string</type>
            <type id="card">string</type>
            <type id="number">string</type>
        </types>
    </xsl:variable>

    <xsl:variable name="templates" select="/database/card[@template='true']"/>
    <xsl:key name="labelIds" match="/database/label" use="id"/> <!-- TODO:Impact of multiple files input ? -->

    <xsl:template match="/">
        <db>
            <vaults userId="{$userId}">
                <xsl:apply-templates select="./*"/>
            </vaults>
            <version>1.33.0</version>
        </db>
    </xsl:template>

    <xsl:template match="database">
        <vault id="{$vaultId}" description="{$vaultDesc}" display="{$vaultColor}" icon="{$vaultIcon}">
            <items>
                <xsl:apply-templates select="./card">
                    <xsl:sort select="concat(@template,'-',@id)"/>
                </xsl:apply-templates>
            </items>
        </vault>
    </xsl:template>

    <xsl:template match="card">
        <xsl:variable name="f" select="./field"/>
        <item id="{@id}" shareId="{@shareId}" title="{@title}" template="{@template}" star="{@star}"
              autofill="{@autofill}">
            <display symbol="{@symbol}" color="{@color}"/>
            <xsl:if test="count(@archived) &gt; 0">
                <xsl:attribute name="archived">
                    <xsl:value-of select="@archived"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count(@deleted) &gt; 0">
                <xsl:attribute name="deleted">
                    <xsl:value-of select="@deleted"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count(@star) &gt; 0">
                <xsl:attribute name="star">
                    <xsl:value-of select="@star"/>
                </xsl:attribute>
            </xsl:if>
            <data>
                <metadata>
                    <name>
                        <xsl:value-of select="@title"/>
                    </name>
                    <notes>
                        <xsl:value-of select="./note/text()"/>
                    </notes>
                    <itemUuid>
                        <xsl:copy-of select="./note/text()"/>
                    </itemUuid>
                </metadata>
            </data>
            <content>
                <itemEmail>
                    <xsl:value-of select="$f[@type='email']"/>
                </itemEmail>
                <password>
                    <xsl:value-of select="$f[@type='password']"/>
                </password>
                <urls>
                    <xsl:for-each select="$f[@type='website']">
                        <url>
                            <xsl:value-of select="."/>
                        </url>
                    </xsl:for-each>
                </urls>
                <totpUri></totpUri>
                <passkeys/>
                <itemUsername></itemUsername>
            </content>
            <state>1</state>
            <aliasEmail>null</aliasEmail>
            <contentFormatVersion>6</contentFormatVersion>
            <createTime>
                <xsl:value-of select="@first_stamp"/>
            </createTime>
            <modifyTime>
                <xsl:value-of select="@time_stamp"/>
            </modifyTime>
            <pinned>false</pinned>
            <shareCount>0</shareCount>
            <files>
            </files>
        </item>
    </xsl:template>

    <!--    <xsl:template match="field">
            <xsl:variable name="itemId" select="generate-id(.)"/>
            <xsl:variable name="itemUuid" select="generate-id()"/>
            <xsl:variable name="shareId" select="uuid:randomUUID()"/>
            <item id="{$itemId}" shareId="{$shareId}" state="">
                <content>
                </content>
            </item>
        </xsl:template>-->


</xsl:stylesheet>
