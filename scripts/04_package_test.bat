REM *****************************
REM      INSTALL ON TEST ORG   
REM *****************************

REM Config
SET testOrg=orgAlias
SET packageVersionId=04tP30000005T4bIAE
SET dependencyVersionId=04t4K000002JvUDQA0

REM Install the package dependencies
sf package:install -p %dependencyVersionId% --target-org %testOrg% --wait 30

REM Install the package
sf package:install -p %packageVersionId% --target-org %testOrg% --wait 30

REM Uninstall the package
sf package uninstall --package %packageVersionId% --target-org %testOrg% --wait 30

REM Uninstall the dependencies
sf package uninstall --package %packageVersionId% --target-org %testOrg% --wait 30
