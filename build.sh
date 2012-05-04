# Create the dist directory if needed
if [[ ! -d dist ]]
	then mkdir dist
fi
# Likewise, create the package dir
if [[ ! -d package ]]
	then mkdir package
fi

# Transform the development XSLT to a release file
xsltproc --novalid --xinclude --output package/LatestEdits.xslt lib/freezeEntities.xslt src/LatestEdits.xslt
# Transform the package.xml file, pulling in the README
xsltproc --novalid --xinclude --output package/package.xml lib/freezeEntities.xslt src/package.xml
# Copy Dashboard.ascx to package
cp src/Dashboard.ascx package/Dashboard.ascx
cp src/LatestEditsIcon_32x32.png package/LatestEditsIcon_32x32.png

# Build the ZIP file 
zip -j dist/Vokseverk.LatestEditsDashboard.zip package/* -x \*.DS_Store

# Copy the release XSLT into the dist dir for upgraders
cp package/LatestEdits.xslt dist/LatestEdits.xslt