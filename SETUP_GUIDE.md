# Sifo Setup Guide

## Adding Local SPM Packages to Xcode

Since the packages are created but not yet linked to the main target, follow these steps:

### Step 1: Open the Workspace

```bash
open Sifo.xcworkspace
```

### Step 2: Add Packages via Package Dependencies

1. In Xcode, click on the **Sifo project** (the blue icon at the very top of the Project Navigator)

2. Go to the **Project** (not target) settings

3. Select the **Package Dependencies** tab

4. Click the **"+"** button at the bottom

5. Click **"Add Local..."**

6. Navigate to your Sifo directory and add each package folder one by one:
   - Select `DependencyContainer` folder → Click **"Add Package"**
   - Repeat for:
     - `TodoRepository`
     - `TodoUseCase`
     - `TodoListView`
     - `TodoDetailView`
     - `TodoUI`
     - `TabBarView`
     - `DevPreview`

### Step 3: Link Packages to Sifo Target

1. Select the **Sifo target** (under TARGETS in the project settings)

2. Go to the **"General"** tab

3. Scroll down to **"Frameworks, Libraries, and Embedded Content"**

4. Click the **"+"** button

5. You should now see all the package products available. Add:
   - `DependencyContainer`
   - `TodoRepository`
   - `TodoUseCase`
   - `TodoListView`
   - `TodoDetailView`
   - `TodoUI`
   - `TabBarView`

6. Make sure they're all set to **"Do Not Embed"** (which should be the default for SPM packages)

### Step 4: Build and Run

Press **Cmd+B** to build. The project should now compile successfully!

## Alternative: Use File → Add Package Dependencies

If the above doesn't work, try this alternative approach:

1. In Xcode menu: **File** → **Add Package Dependencies...**

2. Click **"Add Local..."** at the bottom left

3. Navigate to each package folder and add them

4. After adding all packages, they should automatically be linked to the target

## Troubleshooting

### "No such module" errors persist

1. Clean build folder: **Product** → **Clean Build Folder** (Shift+Cmd+K)
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Restart Xcode
4. Build again

### Packages don't appear in Package Dependencies

Make sure you're:
- Opening `Sifo.xcworkspace` (NOT `Sifo.xcodeproj`)
- The workspace includes all package folders (check `contents.xcworkspacedata`)

### Build errors about missing files

The workspace should have all packages added. Check `Sifo.xcworkspace/contents.xcworkspacedata` contains all FileRef entries for each package.

## Verification

After successful setup, you should be able to:
1. Build without errors
2. See the packages in the Project Navigator (left sidebar)
3. Import modules in Swift files without "No such module" errors
4. Run the app and see the todo list interface

## Quick Verification Build

```bash
cd /Users/obada/Developer/Sifo
xcodebuild -workspace Sifo.xcworkspace -scheme Sifo -destination 'platform=iOS Simulator,name=iPhone 16' clean build
```

If this succeeds, everything is properly configured!
