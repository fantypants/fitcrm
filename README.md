# Fitcrm


# Modules
- Questionaire
- Meals
- Foods
- Uploader
- UI/UX
- Workout Plans
- API
- Auth

## Questionaire
- Initial form - DONE
- Placement and Direction
  - Where in Templates?
    - User config, but uses a switch to determine if calculated (One time setup)
  - Where does it redirect too?
    - Directs back to the users template/index page
  - Direction
    - User logs in
    - Checks Initial User setup
    - User hasn't setup
    - Redirects to form
    - Submits form
    - All relevant data compiled and sent to DB
    - Results shown in the users page
- Templates
  - Form
  - Results
  - User Index
- Database control
  - Needs to check initial Configuration
  - Inserts Results into DB
  - Can update if needed
- Validation
- Display


# Meals
- CSV Containing Foods, Quantity, Paramters, Name of Recipe
- Inserts all meals at once on master spreadsheet
- Able to alter in DB
- Able to Export to major CSV for constant updates
## method
- CSV Uploads
- Process the file
- Add Foods to the DB and then Corresponding ID into the MEal DB with correct qty for the id


## Users and days
- Each day has a workouts and has meals
- Three Meals to a day
- One workout to a day
- Breakfast
- Lunch
- Dinner
- Excercise
- Make each meal have its correct properties and food, (create function which does this to use in each function)
- Add Meal type


## Week planner
- Get Date
- Set Date on Meal of creation
- Set Expiry for 7 days
- Plan the 7 days
