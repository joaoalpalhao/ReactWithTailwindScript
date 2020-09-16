#! /usr/bin/bash
START=$SECONDS

function errorcheck {
    "$@"
    local status=$?
    if (( status != 0 ));
    then
        echo -e "\e[1;41mERROR\e[0m"
        exit 1
    fi
    return $status
}

read -p "App name: " APPNAME
errorcheck npx create-react-app $APPNAME

cd $APPNAME
echo -e "cd into $APPNAME"

echo -e "Adding \e[34mtailwind\e[0m, \e[34mpostcss-cli \e[0mand \e[34mautoprefixer"
errorcheck npm i tailwindcss postcss-cli autoprefixer -D

echo -e "\e[96mInitializing \e[0mtailwind"
errorcheck npx tailwind init --full

echo -e "\e[34mCreating \e[0mpostcss.config.js"
errorcheck cat > postcss.config.js << EOF
module.exports = {
  plugins: [
    require('tailwindcss'),
    require('autoprefixer')
  ]
}
EOF

echo -e "\e[34mCreating \e[0mstyles folder"
cd src
errorcheck mkdir -p styles
cd styles

echo -e "\e[34mCreating \e[0mtailwind.css"
errorcheck cat > tailwind.css << EOF
@tailwind base;

@tailwind components;

@tailwind utilities;
EOF

echo -e "\e[34mCreating \e[0mmain.css"
errorcheck touch main.css
cd ../../

echo -e "\e[93mEditing \e[0mpackage.json"

ORIGIN_STR='"start": "react-scripts start",'
REPLACE_STR='"start": "npm run build:css \&\& react-scripts start",'
errorcheck sed -i "s/$ORIGIN_STR/$REPLACE_STR/" package.json

ORIGIN_STR='"build": "react-scripts build",'
REPLACE_STR='"build": "npm run build:css \&\& react-scripts build",\n\t\t"build:css": "npx tailwindcss build src\/styles\/tailwind.css -o src\/styles\/main.css",'
errorcheck sed -i "s/$ORIGIN_STR/$REPLACE_STR/" package.json

echo -e "\e[95mBuilding \e[0mtailwind"
errorcheck npm run build:css

cd src/
echo -e "\e[93mEditing \e[0mApp.js"

ORIGIN_STR="import React from 'react';"
REPLACE_STR="import React from 'react';\nimport '.\/styles\/main.css';"
errorcheck sed -i "s/$ORIGIN_STR/$REPLACE_STR/" App.js

DURATION=$(( SECONDS - START ))
echo -e "Done - \e[92m$DURATION seconds"
