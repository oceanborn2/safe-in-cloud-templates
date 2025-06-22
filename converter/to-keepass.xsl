<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/database">
        <KeePassFile>
            <Meta>
                <Generator>XSLT SafeInCloud Converter</Generator>
                <DatabaseName>Converted Database</DatabaseName>
                <DatabaseDescription>Imported from SafeInCloud</DatabaseDescription>
                <!-- Add other metadata elements -->
            </Meta>
            <Root>
                <Group>
                    <UUID><xsl:value-of select="generate-id()"/></UUID>
                    <Name>Root</Name>
                    <Notes></Notes>
                    <IconID>48</IconID>
                    <Times>
                        <CreationTime><xsl:value-of select="current-dateTime()"/></CreationTime>
                        <LastModificationTime><xsl:value-of select="current-dateTime()"/></LastModificationTime>
                        <LastAccessTime><xsl:value-of select="current-dateTime()"/></LastAccessTime>
                        <LocationChanged><xsl:value-of select="current-dateTime()"/></LocationChanged>
                        <ExpiryTime><xsl:value-of select="current-dateTime()"/></ExpiryTime>
                        <Expires>False</Expires>
                        <UsageCount>0</UsageCount>
                    </Times>
                    <IsExpanded>True</IsExpanded>

                    <xsl:apply-templates select="card[not(@deleted='true') and not(@template='true')]"/>
                </Group>
            </Root>
        </KeePassFile>
    </xsl:template>

    <xsl:template match="card">
        <Entry>
            <UUID><xsl:value-of select="generate-id()"/></UUID>
            <IconID>0</IconID>
            <Times>
                <CreationTime><xsl:value-of select="current-dateTime()"/></CreationTime>
                <LastModificationTime><xsl:value-of select="current-dateTime()"/></LastModificationTime>
                <LastAccessTime><xsl:value-of select="current-dateTime()"/></LastAccessTime>
                <LocationChanged><xsl:value-of select="current-dateTime()"/></LocationChanged>
                <ExpiryTime><xsl:value-of select="current-dateTime()"/></ExpiryTime>
                <Expires>False</Expires>
                <UsageCount>0</UsageCount>
            </Times>

            <!-- Title -->
            <String>
                <Key>Title</Key>
                <Value><xsl:value-of select="@title"/></Value>
            </String>

            <!-- Process fields -->
            <xsl:apply-templates select="field"/>

            <!-- Notes -->
            <String>
                <Key>Notes</Key>
                <Value><xsl:value-of select="notes"/></Value>
            </String>

            <AutoType>
                <Enabled>True</Enabled>
                <DataTransferObfuscation>0</DataTransferObfuscation>
            </AutoType>
            <History/>
        </Entry>
    </xsl:template>

    <xsl:template match="field[@type='login']">
        <String>
            <Key>UserName</Key>
            <Value><xsl:value-of select="."/></Value>
        </String>
    </xsl:template>

    <xsl:template match="field[@type='password']">
        <String>
            <Key>Password</Key>
            <Value Protected="True"><xsl:value-of select="."/></Value>
        </String>
    </xsl:template>

    <xsl:template match="field[@type='email']">
        <String>
            <Key>URL</Key>
            <Value>mailto:<xsl:value-of select="."/></Value>
        </String>
    </xsl:template>

    <xsl:template match="field">
        <String>
            <Key><xsl:value-of select="@name"/></Key>
            <Value><xsl:value-of select="."/></Value>
        </String>
    </xsl:template>

</xsl:stylesheet>
