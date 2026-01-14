# Sifo User Guide

A comprehensive guide to using the Sifo todo management application.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Managing Todos](#managing-todos)
3. [Organizing with Categories](#organizing-with-categories)
4. [Setting Priorities](#setting-priorities)
5. [Filtering and Viewing](#filtering-and-viewing)
6. [Reordering Todos](#reordering-todos)
7. [CloudKit Sync](#cloudkit-sync)
8. [Tips and Best Practices](#tips-and-best-practices)
9. [Troubleshooting](#troubleshooting)

---

## Getting Started

### What is Sifo?

Sifo is a native iOS todo list application designed for simplicity and efficiency. It helps you:

- Create and manage tasks with rich details
- Organize todos with categories and priorities
- Filter tasks by completion status
- Sync seamlessly across your Apple devices via iCloud

### System Requirements

- **iOS**: 26.0 or later
- **Device**: iPhone or iPad
- **iCloud**: Optional (for cross-device sync)

### First Launch

When you first launch Sifo, you'll see:

1. **Main Tab**: The "Todos" tab displaying your todo list
2. **Empty State**: A helpful message with an "Add Todo" button
3. **Filter Options**: Segment picker showing All / Active / Completed

---

## Managing Todos

### Creating a New Todo

#### Method 1: From Empty State

1. If you have no todos, tap the **"Add Todo"** button in the center of the screen

#### Method 2: From Todo List

1. Tap the **"+"** button in the navigation bar (top right)
2. The "New Todo" form sheet will appear

#### Filling Out the Form

The todo creation form has several sections:

**Details Section:**
- **Title** (required): Enter a descriptive title for your todo
  - Example: "Buy groceries", "Call dentist", "Finish project report"
- **Notes** (optional): Add additional details or context
  - Supports multi-line text
  - Example: "Remember to buy milk, eggs, and bread"

**Due Date Section:**
- Toggle **"Has Due Date"** to enable/disable
- When enabled, select a date using the date picker
- Due dates help you track deadlines and overdue tasks

**Priority Section:**
- Tap the priority picker to select:
  - **None**: No priority (default)
  - **Low**: Low-priority tasks
  - **Medium**: Medium-priority tasks
  - **High**: High-priority tasks
- Priority is displayed with color-coded badges

**Categories Section:**
- Select one or more categories to organize your todo
- Create categories first (see [Organizing with Categories](#organizing-with-categories))
- Checkmarks indicate selected categories

**Saving:**
- Tap **"Save"** to create the todo
- The **Save** button is disabled until you enter a title
- Tap **"Cancel"** to discard changes

**Example:**
```
Title: "Prepare presentation for Monday"
Notes: "Include sales data and Q4 projections"
Due Date: March 15, 2026
Priority: High
Categories: Work, Important
```

### Editing an Existing Todo

1. In the todo list, tap on any todo row
2. The edit form appears with pre-filled data
3. Make your changes
4. Tap **"Save"** to update or **"Cancel"** to discard

**Note:** The navigation title shows "Edit Todo" when editing

### Marking Todos as Complete

#### Method 1: Checkbox

1. Tap the **checkbox** on the left side of any todo row
2. The todo is immediately marked as complete
3. Visual changes:
   - Checkbox becomes filled
   - Title shows strikethrough text
   - Todo may filter out if you're viewing "Active" todos

#### Method 2: Edit Form

1. Open the todo for editing
2. Scroll to the completion status
3. Toggle the switch
4. Save changes

**Tip:** Tap the checkbox again to mark as incomplete

### Deleting Todos

#### Using Swipe Actions

1. Swipe **left** on any todo row
2. Tap the **"Delete"** button (red, with trash icon)
3. A confirmation alert appears:
   - **Delete**: Confirm deletion (permanent)
   - **Cancel**: Keep the todo

**Important:** Deletion is permanent and cannot be undone. The todo will be removed from all your synced devices.

---

## Organizing with Categories

### What are Categories?

Categories help you organize todos into groups like:
- Work
- Personal
- Shopping
- Health
- Projects

Each category has:
- A name
- A color for visual distinction

### Creating Categories

Currently, categories are created programmatically. Future versions will include a category management UI.

### Viewing Category Tags

On each todo row, categories appear as:
- **Colored tags** below the title
- Each tag shows:
  - A small colored circle
  - The category name
  - A colored background matching the category

**Example:**
```
[🔵 Work]  [🟢 Important]
```

### Filtering by Categories

Future feature: Filter todos by specific categories

---

## Setting Priorities

### Priority Levels

Sifo supports four priority levels:

| Priority | Icon | Color | When to Use |
|----------|------|-------|-------------|
| **None** | - | Gray | Default, no urgency |
| **Low** | ↓ | Blue | Can wait, minor tasks |
| **Medium** | = | Orange | Moderate importance |
| **High** | ↑ | Red | Urgent, important tasks |

### Visual Indicators

Priority badges appear on todo rows showing:
- **Icon**: Arrow up (high), equal (medium), arrow down (low)
- **Color**: Red, orange, blue, or gray
- **Text**: Priority name

**Example:**
```
↑ High    (red)
= Medium  (orange)
↓ Low     (blue)
```

### Best Practices

- Use **High** sparingly for truly urgent tasks
- Most todos should be **None** or **Low**
- Review and adjust priorities regularly
- Combine with due dates for effective time management

---

## Filtering and Viewing

### Filter Options

The segmented picker at the top provides three filters:

#### All
- Shows **all todos** regardless of completion status
- Includes both active and completed tasks
- Best for: Reviewing everything you've done

#### Active
- Shows **only incomplete** todos
- Hides completed tasks
- Best for: Focusing on what needs to be done
- **Default view** for productivity

#### Completed
- Shows **only completed** todos
- Hides active tasks
- Best for: Reviewing what you've accomplished

### Switching Filters

1. Tap on any of the three filter options
2. The list automatically refreshes
3. The selected filter is highlighted

**Tip:** The filter remains active until you change it, even after closing and reopening the app.

### Empty States

When a filter returns no results, you'll see:
- **Icon**: Checklist symbol
- **Message**: "No todos yet"
- **Action**: "Add Todo" button

---

## Reordering Todos

### Drag and Drop

Sifo supports manual reordering via drag and drop:

#### Enabling Edit Mode

1. Tap the **"Edit"** button in the navigation bar (top left)
2. Reorder handles (≡) appear on the right side of each row

#### Reordering Steps

1. Press and hold the **reorder handle** (≡)
2. Drag the todo up or down
3. Release when in the desired position
4. Tap **"Done"** to exit edit mode

**Features:**
- Reorder within the current filter view
- Changes are saved immediately
- Syncs across devices via CloudKit

**Note:** Custom order is preserved within your current filter (All, Active, or Completed)

---

## CloudKit Sync

### What is CloudKit Sync?

Sifo uses Apple's CloudKit to automatically sync your todos across all your devices:

- **iPhone** ↔ **iPad** ↔ **Mac** (future support)
- Sync happens automatically in the background
- No manual action required

### Requirements

- Same Apple ID on all devices
- iCloud enabled in Settings
- Internet connection

### How Sync Works

1. **Create/Edit/Delete** on any device
2. Changes are saved locally first
3. CloudKit uploads changes to iCloud
4. Other devices download and apply changes
5. All devices stay in sync

### Sync Indicators

- No manual sync button needed
- Changes appear on other devices within seconds
- If offline, changes sync when connection is restored

### Conflict Resolution

CloudKit automatically handles conflicts when:
- The same todo is edited on multiple devices simultaneously
- The most recent change wins
- No data is lost

### Troubleshooting Sync

If sync isn't working:

1. **Check iCloud Settings**
   - Open Settings → [Your Name] → iCloud
   - Ensure "iCloud Drive" is enabled
   - Scroll down and enable Sifo

2. **Check Internet Connection**
   - Sync requires internet (Wi-Fi or cellular)
   - Changes queue and sync when online

3. **Force Refresh**
   - Pull down on the todo list to refresh
   - This re-fetches data from CloudKit

4. **Sign Out and Back In**
   - Settings → [Your Name] → Sign Out
   - Sign back in with your Apple ID
   - Re-enable iCloud for Sifo

---

## Tips and Best Practices

### Productivity Tips

1. **Start with Active Filter**
   - Focus on incomplete tasks
   - Reduces clutter from completed todos

2. **Use Priorities Wisely**
   - Reserve "High" for truly urgent tasks
   - Most tasks should be "None" or "Low"
   - Review and adjust daily

3. **Set Due Dates**
   - Add due dates to time-sensitive tasks
   - Visual indicators show overdue and due today

4. **Break Down Large Tasks**
   - Create separate todos for multi-step projects
   - Use categories to group related tasks

5. **Review Completed Todos**
   - Switch to "Completed" filter
   - Review what you've accomplished
   - Delete old completed todos periodically

### Organization Tips

1. **Use Categories Consistently**
   - Create categories for major areas (Work, Personal, Health)
   - Apply categories when creating todos
   - Visual tags help quickly identify todo types

2. **Custom Order**
   - Drag important todos to the top
   - Group related todos together
   - Reorder within your Active filter

3. **Notes for Context**
   - Add details in the Notes field
   - Include links, references, or subtasks
   - Helps you remember context later

### Maintenance Tips

1. **Regular Cleanup**
   - Delete old completed todos weekly
   - Archive important completed items elsewhere
   - Keeps the app fast and focused

2. **Periodic Review**
   - Review todos weekly
   - Update priorities and due dates
   - Mark obsolete todos as complete or delete

---

## Troubleshooting

### Common Issues

#### "Save" Button is Disabled

**Problem:** Can't save a new or edited todo

**Solution:**
- Ensure the **Title** field is not empty
- Title must contain at least one non-whitespace character
- The Save button enables automatically when valid

#### Todo Doesn't Appear After Saving

**Problem:** Created a todo but it's not in the list

**Solution:**
1. Check your **current filter**:
   - If viewing "Completed", new todos won't show (they're active)
   - Switch to "All" or "Active" filter
2. Pull down to **refresh** the list
3. If still missing, check CloudKit sync status

#### Can't Delete Todo

**Problem:** Delete action doesn't work

**Solution:**
1. Swipe **left** on the todo row (not right)
2. Tap the **Delete** button
3. Confirm deletion in the alert
4. If swipe doesn't work, check for iOS updates

#### Todos Not Syncing

**Problem:** Changes on one device don't appear on another

**Solution:**
- See [CloudKit Sync - Troubleshooting](#troubleshooting-sync) section above

#### Checkbox Not Responding

**Problem:** Tapping checkbox doesn't toggle completion

**Solution:**
1. Ensure you're tapping the **checkbox** (left side), not the row
2. Wait a moment for the update to process
3. Pull down to refresh if state seems stuck

#### Filter Not Working

**Problem:** Filter doesn't show expected todos

**Solution:**
1. Verify you're on the correct filter (All/Active/Completed)
2. Pull down to refresh
3. Check if todos actually match the filter criteria:
   - Active = not completed
   - Completed = marked as done

#### App Crashes or Freezes

**Problem:** App becomes unresponsive

**Solution:**
1. **Force quit** and reopen:
   - Swipe up from bottom (or double-click Home)
   - Swipe up on Sifo preview
   - Relaunch from Home Screen
2. **Restart device** if problem persists
3. **Update to latest version** in App Store
4. Contact support if issue continues

### Error Messages

#### "Title cannot be empty"

**Cause:** Attempted to save a todo without a title

**Fix:** Enter text in the Title field

#### "Failed to load todos"

**Cause:** Network or database error

**Fix:**
1. Check internet connection
2. Pull down to refresh
3. Restart the app

#### "Failed to delete"

**Cause:** Database or sync error

**Fix:**
1. Try again
2. Check internet connection
3. Restart the app

#### "An unexpected error occurred"

**Cause:** Unknown error

**Fix:**
1. Note what action caused the error
2. Restart the app
3. Try the action again
4. Contact support if it persists

---

## Feature Requests and Feedback

### Planned Features

Future updates may include:
- Category management UI
- Search and advanced filtering
- Recurring todos
- Subtasks and checklists
- Widgets for Home Screen
- Apple Watch support

### Providing Feedback

To request features or report issues:
1. Check the GitHub repository for known issues
2. Submit feedback via the App Store
3. Contact the development team

---

## Privacy and Data

### What Data is Stored?

Sifo stores:
- Todo titles and notes
- Completion status
- Due dates and priorities
- Categories and associations

### Where is Data Stored?

- **Locally**: On your device using SwiftData
- **iCloud**: Synced via CloudKit (if enabled)
- **No third-party servers**: Your data never leaves Apple's ecosystem

### Privacy Commitment

- No analytics or tracking
- No third-party data sharing
- Your todos are private to you
- Data is encrypted in iCloud

---

## Keyboard Shortcuts

Future feature: Keyboard shortcuts for iPad and Mac

---

## Accessibility

Sifo is designed with accessibility in mind:

- **VoiceOver**: Full support for screen readers
- **Dynamic Type**: Text scales with system settings
- **Color Contrast**: High contrast for readability
- **Reduce Motion**: Respects system animation preferences

---

## Glossary

| Term | Definition |
|------|------------|
| **Todo** | A task or item to be completed |
| **Category** | A label for organizing related todos |
| **Priority** | Importance level (None, Low, Medium, High) |
| **Filter** | View option to show All, Active, or Completed todos |
| **Adapter** | Internal term for data transformation (not visible to users) |
| **CloudKit** | Apple's cloud sync service |
| **SwiftData** | Apple's local database framework |

---

## Quick Reference

### Common Actions

| Action | How To |
|--------|--------|
| Create todo | Tap **+** button |
| Edit todo | Tap on todo row |
| Mark complete | Tap **checkbox** |
| Delete todo | Swipe left → Delete |
| Filter view | Tap filter segment (All/Active/Completed) |
| Reorder | Edit mode → drag handle (≡) |
| Refresh | Pull down on list |

### Keyboard Shortcuts (Future)

Coming in a future update

---

## Support

For additional help:
- Consult the [Developer Guide](DEVELOPER_GUIDE.md) for technical details
- Review the [Architecture Documentation](ARCHITECTURE.md)
- Check the GitHub repository for updates

---

**Last Updated:** January 2026
**Version:** 1.0
**Platform:** iOS 26.0+
