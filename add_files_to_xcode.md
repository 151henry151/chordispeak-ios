# Adding Files to Xcode Project

Follow these steps to add the new Swift files to your Xcode project:

## Step 1: Open Xcode Project
1. Open `chordispeak.xcodeproj` in Xcode
2. In the Project Navigator (left sidebar), expand the `chordispeak` folder

## Step 2: Add Files to Project
For each of the following files, right-click on the `chordispeak` folder and select "Add Files to chordispeak":

### Required Files to Add:
1. **Models.swift** - Data models and enums
2. **ChordiSpeakAPI.swift** - API client for backend communication
3. **ChordiSpeakViewModel.swift** - View model for business logic
4. **AudioFilePicker.swift** - Document picker for audio files
5. **ProcessingProgressView.swift** - Progress display components
6. **ChordProgressionView.swift** - Chord timeline and summary views

## Step 3: Add Files Process
For each file:
1. Right-click on the `chordispeak` folder in Project Navigator
2. Select "Add Files to chordispeak"
3. Navigate to the file location
4. Make sure "Add to target: chordispeak" is checked
5. Click "Add"

## Step 4: Verify Files Added
After adding all files, you should see them in the Project Navigator:
```
chordispeak/
├── chordispeakApp.swift
├── ContentView.swift
├── Models.swift
├── ChordiSpeakAPI.swift
├── ChordiSpeakViewModel.swift
├── AudioFilePicker.swift
├── ProcessingProgressView.swift
├── ChordProgressionView.swift
├── Assets.xcassets/
└── Preview Content/
```

## Step 5: Configure Signing
1. Select the `chordispeak` target in the Project Navigator
2. Go to "Signing & Capabilities" tab
3. Select your development team
4. Or choose "Automatically manage signing"

## Step 6: Configure Info.plist
Add these keys to your Info.plist:

### Network Security
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Document Access
```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs access to documents to save processed audio files</string>
```

## Step 7: Build and Test
1. Clean the build folder (Product → Clean Build Folder)
2. Build the project (⌘+B)
3. Run the app (⌘+R)

## Troubleshooting

### If files don't appear in Project Navigator:
- Make sure you selected "Add to target: chordispeak"
- Check that files are in the correct folder

### If build errors persist:
- Clean build folder and rebuild
- Check that all files are added to the target
- Verify Info.plist configuration

### If signing issues occur:
- Select your development team in Signing & Capabilities
- Or use "Automatically manage signing" 