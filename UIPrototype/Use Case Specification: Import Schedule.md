## Use Case Specification: Import Schedule

### 1. Use Case Name

- Import Schedule

### 2. Participating Actors

- End User (Primary Actor)
- SJTU network & information center (Secondary Actor)

### 3. Precondition

- The user must be logged into the application with valid credentials.

### 4. Postcondition

- The schedule is successfully imported and displayed on the main interface, or an appropriate error message is displayed if the import fails.

### 5. Trigger

- The user selects the option to import their schedule.

### 6. Normal Flow

1. The user selects "Import Schedule" from the application menu.
2. The system presents two options: "Import from School Academic System" and "Manually Add Courses."
3. If the user selects "Import from School Academic System":
   1. The system prompts the user to log in to their jAccount.
   2. Upon successful authentication, the system retrieves the schedule from the School Academic System.
   3. The system imports the courses into the user's schedule on the main interface.
4. If the user selects "Manually Add Courses":
   1. The user is presented with a form to enter course details: course name, time, teacher, and location.
   2. The user can also input course details using natural language (e.g., "Thursday in room 101, Advanced Mathematics by Professor Wang Gang").
   3. The system processes the natural language input or form data to create a new course entry.
   4. The system adds the course to the user's schedule on the main interface.

### 7. Alternative Flows

- If the jAccount authentication fails, the system displays an error message and prompts the user to re-enter their credentials.
- If the user inputs course details using natural language and the system cannot recognize the input, the system prompts the user to input the details through the form.
- If the system cannot import the schedule after successful jAccount authentication because the School Academic System has not updated the schedule:
  1. The system notifies the user that the schedule is currently unavailable because it hasn't been updated by the School Academic System yet.
  2. The system suggests the user to try importing the schedule later or to manually add courses in the meantime.

### 8. Exception Flows

- If there is a time conflict between a new course and an existing course in the user's schedule:
  1. The system notifies the user of the conflict.
  2. The user can either adjust the conflicting course details or cancel the new course addition.
- If the user attempts to import from the School Academic System when the local schedule is not empty:
  1. The system warns the user that this action will overwrite the existing schedule.
  2. The user can choose to proceed (which overwrites the existing schedule) or cancel the import action.

### 9. Special Requirements

- The system should validate the format of the schedule data from the School Academic System to match the application's requirements.
- Natural language processing must be able to handle a range of expressions for adding courses.
