REM *****************************
REM        PACKAGE CREATION   
REM *****************************

REM Package Create Config
SET devHub=devHubAlias
SET packageName=Lightweight - REST Util
SET packageDescription=A lightweight Apex utility for executing (Salesforce / Data Cloud) REST based APIs
SET packageType=Managed
SET packagePath=force-app/package

REM Package Config
SET packageId=0HoP30000000001KAA
SET packageVersionId=04tP3000000wMhhIAE

REM Create package
sf package create --name "%packageName%" --description "%packageDescription%" --package-type "%packageType%" --path "%packagePath%" --target-dev-hub %devHub%

REM Create package version
sf package version create --package "%packageName%"  --target-dev-hub %devHub% --code-coverage --installation-key-bypass --wait 30

REM Delete package
sf package:delete -p %packageId% --target-dev-hub %devHub% --no-prompt

REM Delete package version
sf package:version:delete -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM Promote package version
sf package:version:promote -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM /packaging/installPackage.apexp?p0=04tP3000000wMhhIAE

