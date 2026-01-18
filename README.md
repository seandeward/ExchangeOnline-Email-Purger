# Exchange Online Email Purger

This is a cybersecurity tool to delete an email from every user's inbox. I use this at my job __all the time__ to delete malicious phishing emails that were sent out to large amounts of people.

This was built because our company receives phishing emails that go out to many different users, and it is incredibly challenging to communicate with them one at a time. (Many of those people that I would communicate with have already clicked on it lol).

This automated script is intended to delete those emails from the user's inbox, __preventing them from seeing it in the first place__.

## How to Build/Run

__You will need an admin-level email account__ for your Exchange Online service to run this script.

You can run the program in a terminal or in your IDE/ISE of choice.

### Configuration

No configuration required. You are able to run the script as is in your environment.

You will be asked to fill a set of variables one at a time that determine the email you want to get rid of, such as the sender's address and email subject. The program is built to be easy to follow and understand.

## Detailed Script Process

- Upon startup, the script will check for any available updates to the ExchangeOnlineManagement module and install them (this is added because of an earlier version running into problems due to the module being outdated).
- It defines the DisplaySetupConfiguration function, which creates a menu that displays the variables used to delete the email. A set of variables with placeholder values (as a failsafe, depending on where the script ends) are also loaded.
- A while loop begins until the user confirms all the variables they put in.
- Script imports the ExchangeOnlineManagement module, and connects.
- User is asked to enter in their admin credentials for Exchange.
- A Compliance Search is created using the variables the user entered at the start of the script.
- Script enters a while loop until the search status is "Completed"
- When the status is "Completed", the results of the search are shown to the user.
- If the amount of matching emails (stored in variable $resultItems) is greater or equal to 1, the user is asked if they want to purge those matching emails, permanently deleting them from everyone's inboxes.
- If user selects Yes, all matching emails are deleted. If they select No, the emails remain. Either way, the script disconnects from the ExchangeOnline session and the script ends.

## Rundown of Development Process

### Starting with Automation

I developed this with a set of commands by boss was manually entering one at a time. The problem is that, after you start a search, you have to manually check the search's progress manually as well, meaning it could be done way before you check it. That's really inefficient and slow if you want to delete malicious emails asap.

I saw this as a great opportunity to automate this whole process using a while loop so that you would know when the search is done by checking the search's status over and over again.

## Wishlist of Future Features
### GUI

I'd love to add some kind of GUI to this, as that would provide a smoother modern way to enter the search criteria.
