# Issue With Android Permissions in Delphi 10.4.1 (Sydney)

## ISPermissions
The PermissionsService.RequestPermissions function was introduced in Rio and I set up a library (ISPermissions) to document and codify my use and understanding of this requirement.
## Delphi 10.4.1 Sydney
The Introduction of Delphi 10.4.1 resulted in the GPS functions operating differently but more concerning I was no longer able to set up permissions to write to the "ShareDocuments" Folder
### Shared Documents
Rio allowed me to place data in Shared Documents by setting the READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE permissions. In 10.4.1 I get exceptions when I attempt to write to that directory even after the permissions are set.
### GPS Permissions
Programs compiled in Rio have three options when interacting with the user - "Allow all the time", "Allow only while using the app" and "Deny". Applications compiled in Sydney have only the last two options.
## Sample Projects
The repository contains two sampl projects
### AndroidPermRioSydney
A single form multiplatform application using the ISPermissions library
### AndroidPermRioSydneyMin
A single form multiplatform application with minimal functionality of the ISPermissions library coded into the form produced to report the issue.
## More Information After Discussion with Support
TPath.GetSharedDocumentsPath currently uses "getExternalStoragePublicDirectory" which has been deprecated in API level 29 see:
https://developer.android.com/reference/android/os/Environment#getExternalStoragePublicDirectory(java.lang.String)
I tried GetExternalDocumentsDir from Androidapi.IOUtils as suggested and the files are saved but they buried under files/documents in the application folder.

Delphi 10.3 Rio Targets API Level Android 26

Delphi 10.4 Sydney Targets API Level Android 29 (Android 10)

Data Storage changes and permissions required change between these versions https://developer.android.com/training/data-storage
 
The "Approved" way to share files between apps in Android is via a FFile Provider https://developer.android.com/training/secure-file-sharing/setup-sharing



