#!/usr/bin/env bash

atomDir="$HOME/.atom"
makeDir $atomDir

cat > $atomDir/keymap.cson << EOF
'atom-text-editor':
  'ctrl-d': 'editor:duplicate-lines'
  'ctrl-backspace': 'editor:delete-line'
EOF

cat > $atomDir/config.cson << EOF
"*":
  core:
    openEmptyEditorOnStart: false
    telemetryConsent: "no"
  editor:
    fontSize: 16
    preferredLineLength: 120
    showInvisibles: true
    tabLength: 4
  welcome:
    showOnStartup: false
EOF
