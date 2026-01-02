<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xsi:schemaLocation="http://www.w3.org/2005/02/xpath-functions">


    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:variable name="labels" select=".//label"/>
    <xsl:param name="dbname"/> <!-- database name parameter -->
    <xsl:param name="dbdesc"/> <!-- database description parameter -->


    <xsl:template match="/database">
        <KeePassFile>
            <Meta>
                <Generator>XSLT SafeInCloud to keepass Converter</Generator>
                <DatabaseName>
                    <xsl:value-of select="$dbname"/>
                </DatabaseName>
                <DatabaseDescription>
                    <xsl:value-of select="$dbdesc"/>
                </DatabaseDescription>
                <!-- Add other metadata elements -->
            </Meta>
            <Root>
                <Group>
                    <UUID>
                        <xsl:value-of select="generate-id()"/>
                    </UUID>
                    <Name>Root</Name>
                    <Notes></Notes>
                    <IconID>48</IconID>
                    <Times>
                        <xsl:variable name="currtime" select="current-dateTime()"/>
                        <CreationTime>
                            <xsl:value-of select="$currtime"/>
                        </CreationTime> <!--TODO: base64 encoded or encrypted ?-->
                        <LastModificationTime>
                            <xsl:value-of select="$currtime"/>
                        </LastModificationTime>
                        <LastAccessTime>
                            <xsl:value-of select="$currtime"/>
                        </LastAccessTime>
                        <LocationChanged>
                            <xsl:value-of select="$currtime"/>
                        </LocationChanged>
                        <ExpiryTime>
                            <xsl:value-of select="$currtime"/>
                        </ExpiryTime>
                        <Expires>False</Expires>
                        <UsageCount>0</UsageCount>
                    </Times>
                    <IsExpanded>True</IsExpanded>

                    <!-- TODO: could copy templates as well -->
                    <xsl:apply-templates select="card[not(@deleted='true') and not(@template='true')]"/>
                </Group>
            </Root>
        </KeePassFile>
    </xsl:template>

    <xsl:template match="card">
        <Entry>
            <UUID>
                <xsl:value-of select="@id"/>
                <!--xsl:value-of select="generate-id()"-->
            </UUID>
            <IconID>0</IconID>
            <Times>
                <xsl:variable name="timestamp" select="current-dateTime()"/>
                <CreationTime>
                    <xsl:value-of select="@first_timestamp"/>
                </CreationTime>
                <LastModificationTime>
                    <xsl:value-of select="@time_stamp"/>
                </LastModificationTime>
                <LastAccessTime>
                    <xsl:value-of select="$timestamp"/>
                </LastAccessTime>
                <LocationChanged>
                    <xsl:value-of select="$timestamp"/>
                </LocationChanged>
                <ExpiryTime>
                    <xsl:value-of select="$timestamp"/>
                </ExpiryTime> <!-- TODO:cli parameter or default value ? -->
                <Expires>False</Expires>
                <UsageCount>0</UsageCount>
            </Times>

            <!-- Title -->
            <String>
                <Key>Title</Key>
                <Value>
                    <xsl:value-of select="@title"/>
                </Value>
            </String>

            <!-- Process fields -->
            <xsl:apply-templates select="field"/>

            <!-- Notes -->
            <String>
                <Key>Notes</Key>
                <Value>
                    <xsl:value-of select="notes"/>
                </Value>
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
            <Value>
                <xsl:value-of select="."/>
            </Value>
        </String>
    </xsl:template>

    <xsl:template match="field[@type='password']">
        <String>
            <Key>Password</Key>
            <Value Protected="True">
                <xsl:value-of select="."/>
            </Value>
        </String>
    </xsl:template>

    <xsl:template match="field[@type='email']">
        <String>
            <Key>URL</Key>
            <Value>mailto:<xsl:value-of select="."/>
            </Value>
        </String>
    </xsl:template>

    <xsl:template match="field">
        <String>
            <Key>
                <xsl:value-of select="@name"/>
            </Key>
            <Value>
                <xsl:value-of select="."/>
            </Value>
        </String>
    </xsl:template>

    <!-- conversion from epoch to date time, borrowed the code from https://stackoverflow.com/questions/19271594/converting-epoch-to-date-time-with-time-zone-in-xslt-2-0-->
    <xsl:function name="fn:epochToDate">
        <xsl:param name="epoch"/>
        <xsl:variable name="dayTimeDuration" select="concat('PT',$epoch,'S')"/>
        <xsl:value-of select="xs:dateTime('1970-01-01T00:00:00') + xs:dayTimeDuration($dayTimeDuration)"/>
    </xsl:function>

</xsl:stylesheet>
