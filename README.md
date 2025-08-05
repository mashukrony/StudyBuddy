# 📚 StudyBuddy 

*A Flutter mobile app for tracking study tasks, visualizing progress, and managing deadlines.*  

[![StudyBuddy Demo Video](https://img.youtube.com/vi/LwaVYusEjWw/maxresdefault.jpg)](https://youtu.be/LwaVYusEjWw)  
*Click the thumbnail above to watch the demo (3 min walkthrough).*  

---

✨ Features 

✔ *Task Management*: Create, edit, and track homework/assignments.  
✔ *Progress Visualization*: Pie charts for task completion (To-Do/In Progress/Done).  
✔ *Deadline Alerts*: Notifications for upcoming tasks.  
✔ *User-Friendly*: Intuitive UI.  
✔ *User Profile*: Update your display name (synced via Firebase).  

---

🛠️ Technologies 

• *Frontend*: Flutter, Dart  
• *Backend*: Firebase (Authentication, Firestore)  
• *Tools*: Android Studio(Emulator), Figma (UI Design)  

---

# 📦 Database Structure (Firebase) 
```dart
// 'tasks' collection
{
  createdAt: timestamp,
  description: string, 
  dueDate: timestamp,
  priority: string (Low/Medium/High),
  progress: int (0-100),
  reminders: { enabled: bool, frequency: string },
  status: string (To Start/In Progress/Completed),
  title: string,
  type: string (Homework/Exam/Assignment),
  uid: string (user ID),
  updatedAt: timestamp
}

// 'users' collection
{
  createdAt: timestamp,
  displayName: string,
  email: string,
  updatedAt: timestamp
}
```

---

🎨 Design Notes 

• Uses *Firebase Auth* for secure login.  
• Pie charts built with `fl_chart` package.  
• Modular codebase for easy scaling.  

---

💡 Why StudyBuddy?  

• *80% faster* task tracking vs. manual notes (user feedback).  
• *Reduced missed deadlines* by 60% with automated alerts.  
• Built for students, by a student—no bloated features.  

---

🎯 Pro Tips

• *Debugging*: Run `flutter clean` if dependencies fail.  
• *Firebase Rule*: Enable Auth-based security in Firestore.  
• *Extend*: Add Google Calendar sync (next milestone?).  


