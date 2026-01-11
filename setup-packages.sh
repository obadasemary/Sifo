#!/bin/bash

echo "🔧 Setting up SPM packages for Sifo..."
echo ""
echo "⚠️  This requires Xcode to be closed."
echo ""
read -p "Have you closed Xcode? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Please close Xcode and run this script again."
    exit 1
fi

echo ""
echo "📦 Packages to add:"
echo "  - DependencyContainer"
echo "  - TodoRepository"
echo "  - TodoUseCase"
echo "  - TodoListView"
echo "  - TodoDetailView"
echo "  - TodoUI"
echo "  - TabBarView"
echo ""
echo "Since modifying project.pbxproj programmatically is complex and error-prone,"
echo "please follow these manual steps in Xcode:"
echo ""
echo "1. Open: open Sifo.xcworkspace"
echo ""
echo "2. In Xcode, select the Sifo project (blue icon)"
echo ""
echo "3. Select the 'Sifo' target → 'General' tab"
echo ""
echo "4. Scroll to 'Frameworks, Libraries, and Embedded Content'"
echo ""
echo "5. Click '+' → 'Add Other...' → 'Add Package Dependency...'"
echo ""
echo "6. Click 'Add Local...' and add each package folder listed above"
echo ""
echo "7. After adding all packages, you may need to select which products"
echo "   to link (select the library for each package)"
echo ""
echo "8. Build the project: Cmd+B"
echo ""
echo "✅ The packages will then be available for import!"
