#aliases--------------------------------------
alias active='cd && cd Dev/_active'
alias client='cd && cd Dev/_supreme/production/client'
alias confish='charm /Users/jakobbellamy/.config/fish/'
alias d1='touch index.js && mkdir src && cd src/ && mkdir models && mkdir controllers && mkdir routes && cd routes && touch routes.js && cd .. && cd .. && sublime . && npm i express cors lodash body-parser mongoose'
alias dev='cd && cd Dev/'
alias digest='cd && cd Dev/_supreme/monthlyDigester'
alias gclear='git rm -r --cached .'
alias logs='heroku logs --tail'
alias makemigrations='python manage.py makemigrations'
alias migrate='python manage.py migrate'
alias newsuper createsuperuser
alias personal='cd && cd Dev/_personal'
alias pip=pip3
alias py=/usr/local/bin/python3
alias python=/usr/local/bin/python3
alias reportCard='cd && cd Dev/_supreme/supremeMongo/src/reportCardGenerator'
alias runserver='python manage.py runserver'
alias school='cd && cd Dev/_school/assignments'
alias server='cd && cd Dev/_supreme/production/server'
alias shell='python manage.py shell'
alias sqlmigrate='python manage.py sqlmigrate'
alias startapp='python manage.py startapp'
alias env='charm /Users/jakobbellamy/Dev/env_vars/.env'
alias remignore='git rm -r --cached . && git add . && git commit -am "Remove ignored files"'
alias gc='git add . && git commit -m'
alias gp='git push'
alias charm='open -a "Pycharm.app"'
alias storm='open -a "WebStorm.app"'
alias grip='Open -a "DataGrip.app"'

function agit -a message
  git add .

  if not test -n "$message"
    git commit -m "Auto Commit"
  else
    git commit -m "$message"
  end

  git push
end

function icloud
  cd 
  cd (pwd)/Library/Mobile Documents/com~apple~CloudDocs
end

function clonePgSupreme -a new_db target_db
  if test -n "$target_db"
    heroku pg:pull DATABASE_URL "$new_db" -a "$target_db"
  else
    heroku pg:pull DATABASE_URL "$new_db" -a djsupreme
  end
end

function clonePgLocal -a new_db target_db
  set -l origin (pwd)
  cd
  cd Dev/_psql_scripts

  if test -n "$target_db" 
    set -a tdb "$target_db"
  else
    set -l tdb dev_local
  end

  if not test -e (pwd)/copy_pg.sql
    echo clone_pg.sql not found in (pwd)
  else
    set -l script (string split '%' (cat (pwd)/copy_pg.sql))
    echo > temp.sql $script[1] "$new_db" $script[2] $tdb $script[3]

    psql -U jakobbellamy -a -f (pwd)/temp.sql

    # rm temp.sql
    cd $origin
  end


end

#git push --set-upstream origin $branch
function setUp -a branch
  git push --set-upstream origin $branch
end
#new python practice file
function npr -a num
  touch _"$num"_practice.py
end

function opr -a num
  python3 _"$num"_practice.py
end

#remove all files in current directory
function rmAll
   set -l arr (ls *)
   for file in $arr
       rm $file
   end
end

function sandbox
  cd
  cd Dev/_sandbox
  if test -e ~/Dev/_sandbox/(date +'%Y-%m-%d')
    cd (date +'%Y-%m-%d')
  else
    mkdir (date +'%Y-%m-%d')
    cd (date +'%Y-%m-%d')
  end
end

function newAssignment -a title
  cd
  cd Dev/_school/assignments
  mkdir "$title"
  cd "$title"
  touch run.py
  sublime .
end

#start new "sandbox" folder/script
function newSandbox -a type
 cd
 cd Dev/_sandbox
 if test -e ~/Dev/_sandbox/(date +'%Y-%m-%d')
     cd (date +'%Y-%m-%d')
     touch script(math (count *."$type"))."$type"
     sublime .
 else
     mkdir (date +'%Y-%m-%d')
     cd (date +'%Y-%m-%d')
     touch script0."$type"
     sublime .
 end
end

#returns string in title_case
function title_case -a string
  set -l matches (string match -r -a '\b[a-z]' $string)
  for match in $matches
    set -l upper (echo $match | tr a-z A-Z)
    set string (echo (string replace -r '\b[a-z]' $upper $string))
  end
  echo $string
end

#prints file contents to console
function printFile -a file
  printf '%s\n' (less $file)
end

#writes string to file
function writeTo -a file string
  echo > $file $string
end

#writes node index
function writeIndex -a name
  echo > index.js "//dependencies
  const express = require('express');
  const bodyParser = require('body-parser');
  const mongoose = require('mongoose');
  const cors = require('cors');
  //node init
  const app = express().use(cors());
  const PORT = 5000;
  //DB connection init
  mongoose.Promise = global.Promise;
  mongoose.connect('mongodb://localhost:27017/$name, {useNewUrlParser: true, useUnifiedTopology: true});
  //init app w/ body parser
  app
  .use(bodyParser.urlencoded({extended: true}))
  .use(bodyParser.json());
  //router setup
  const router = require('./src/routes/routes.js');
  router(app);
  //test serve @ root ('/')
  app.get('/', (req, res) => {
     res.send(`Node and Express are running on port: \${PORT}`);
     console.log('server hit at root')
  });
  //listen @ PORT
  app.listen(PORT, () => {
     console.log(`Your server is running on port: \${PORT}`);
  });"
end

#generates a boiler plate Mongo Express Node directory
function genMen -a name
  set -l count (count *)
  if begin ; test -e ./package.json ; and test $count = 1 ; end
    touch index.js
    writeIndex $name
    mkdir ./src/
    cd ./src/
    mkdir ./routes/
    mkdir ./controllers/
    mkdir ./models/
    mkdir ./middleware/
    cd ./routes/ && touch routes.js
    cd ../..
    sublime .
    npm i express cors lodash body-parser mongoose
  else
    echo "no package.json found in this directory. cd into an empty node directory"
  end
end

#generates a mongo model
function genModel -a name upperName attributes
  set -l arr (string split ',' $attributes)
  echo > "src/models/"$name".js" "const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const "$upperName"Schema = new Schema({"
  for val in $arr
    set -l spl (string split ':' $val)
    set -l at $spl[1]
    set -l type (title_case $spl[2])

    echo >> "src/models/"$name".js" "   "$at":{
   type: "$type",
   required: true
  },"
  end

  sed -i '' '$ s/.$//' src/models/$name.js
  echo >> "src/models/"$name".js" "});
  module.exports =  mongoose.model('$upperName', "$upperName"Schema);"
end

#generates models and files for mongo model
function gen -a name attributes
  if begin ; test -e ./package.json ; and test -e src/models ; and test -e src/controllers ; and test -e src/routes ; end
    touch 'src/models/'$name'.js'
    touch 'src/controllers/'$name'Controller.js'
    set -l upperName (title_case $name)

    genModel $name $upperName $attributes
  else
    echo "error: make sure youre in a scaffolded node directory" \n"if in a blank directory, npm init --yes && genMen <api name>"
  end
end

#ls penetrate
function lsPen
  for dir in (find * -maxdepth 0 -type d);
     for file in (ls $dir);
         echo $file;
     end;
   end;
 end;
