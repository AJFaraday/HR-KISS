HR-KISS, Human Relations seeded with common sense. 

A simple application for tracking holidays and flex time for companies in the real world. 

Features:
* Simply book holidays and track your holiday allowance.
* Simply record sick days and track your sick day allowance.
* Simple manager acceptance for holidays.
* Absences are recorded down to the half-day.
* Simple absence calendar
* Caledar export in ical (for Google Calendar)
* Simple, easy to use flex-time timeline. 

Upcoming Features (as yet, unfinished):
* email alerts:
* > when manager acceptance is required.
* > when employees are over their holiday or sick-day allowance.
* User-defined exempt days (bank holidays etc.) which won't count against holidays.
* The next year's bank-holidays as seeds.
* Help/demo page when not logged in.

Install process (assumes some Ruby on Rails knowledge):
* git clone https://github.com/AJFaraday/HR-KISS.git)
* cd HR-KISS
* cp config/database.template config/database.yml
* cp config/mail.template config/mail.yml
* (modify config files as required, I suggest creating a gmail account to send HR-KISS notifications)
* bundle install
* rake db:create
* rake db:migrate
* rake db:seed
* rails s
* point your browser at 'localhost:3000'

Notes:
* The application currently assumes a working environment where everyone works 9am-5pm Monday-Friday (in theory), and holidays ignore saturdays and sundays.
* Please don't judge the graphic design elements too harshly, I have applied the KISS philosophy to the design, as well as the UI of the project.

Developers: 
* Andrew Faraday(andrewfaraday@hotmail.co.uk)

KEEP IT SIMPLE, STUPID!
