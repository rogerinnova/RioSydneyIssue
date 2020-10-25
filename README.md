# Issue With Android Permissions in Delphi 10.4.1 (Sydney)
## ISPermissions
The PermissionsService.RequestPermissions function was introduced in Rio and I set up a libray (ISPermissions) to document and codify my use and understanding of this reqirement.
## Delphi 10.4.1 Sydney
The Introduction of Delphi 10.4.1 resulted in the GPS functions operating differently but more concerning I was no longer able to set up permissions to write to the "ShareDocuments" Folder
###Shared Documents
Rio allowed me to place data in Shared Documents by setting the READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE permissions. In 10.4.1 I get exceptions when I attempt to write to that directiory even after the permissions are set.
###GPS Permissions
Programs compiled in Rio have three options when interacting with the user - "Allow all the time", "Allow only while using the app" and "Deny". Applications compiled in Sydney have only the last two options.
##Sample Projects
The repository contains two sampl projects
##AnroidPermRioSydney
A single form multiplatform application using the ISPermissions library
##AnroidPermRioSydneyMin
A single form multiplatform application with minimal functionality of the ISPermissions library coded into the form produced to report the issue.


