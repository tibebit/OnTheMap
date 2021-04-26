# OnTheMap
The On The Map app allows users to share their location and a URL with their fellow students. 
To visualize this data, On The Map uses a map with pins for location and pin annotations for student names and URLs.
## Structure
The app has three view controller scenes:
* **Login View:** Allows the user to log in using their Udacity credentials
* **Map and Table Tabbed View:** Allows users to see the locations of other students in two formats
* **Information Posting View:** Allows the users specify their own locations and links
### Login View
The login view accepts the email address and password that students use to login to the Udacity site.
### Map and Table Tabbed View
This view displays the last 100 locations posted by students with the following formats:
* A Map: if a pin is tapped, it displays the pin annotation popup, with the student’s name (pulled from their Udacity profile) and the link associated with the student’s pin.
* A Table
### Information Posting View
The Information Posting View allows users to input their own data into two textfields:
* An address string which gets geocoded by the system
* A URL

When the user clicks on the “Find Location” button, the app will forward geocode the string.
If the forward geocode succeeds then text fields will be hidden, and a map showing the entered location will be displayed. 
Tapping the “Finish” button will post the location and link to the server.
