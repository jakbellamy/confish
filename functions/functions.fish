#Functions------------------------------------------------------|

function clonePgLocal -a new_db target_db
  set -l origin (pwd)
  set_psql_folder
  cd ~/Dev/_psql_scripts
  if test -n "$target_db"
    set -a tdb "$target_db"
  else
    set -l tdb dev_local
  end
  if not test -e (pwd)/copy_pg.sql
    echo clone_pg.sql not found in (pwd)
    echo Writing clone_pg.sql
    echo > clone_pg.sql create database % with template % owner jakobbellamy;
    echo 'complete :)'
  end
  set -l script (string split '%' (cat (pwd)/copy_pg.sql))
  echo > temp.sql $script[1] "$new_db" $script[2] $tdb $script[3]
  psql -U jakobbellamy -a -f (pwd)/temp.sql
  rm temp.sql
  cd $origin
end

function clonePgHeroku -a new_db target_db
  if test -n "$target_db"
    heroku pg:pull DATABASE_URL "$new_db" -a "$target_db"
  else
    heroku pg:pull DATABASE_URL "$new_db" -a djsupreme
  end
end

function set_psql_folder
  if not test -e ~/Dev/
    mkdir ~/Dev/
  end
  if not test -e ~/Dev/_psql_scripts/
    mkdir ~/Dev/_psql_scripts/
  end
end

function agit -a message
  git add .
  if not test -n "$message"
    git commit -m "Auto Commit"
  else
    git commit -m "$message"
  end
  git push
end

function newBranch -a branch
  git checkout -b "$branch"
  git push --set-upstream origin $branch
end

function rmAll
   set -l arr (ls *)
   for file in $arr
       rm $file
   end
end

function sandbox
  cd ~/Dev/_sandbox
  if test -e ~/Dev/_sandbox/(date +'%Y-%m-%d')
    cd (date +'%Y-%m-%d')
  else
    mkdir (date +'%Y-%m-%d')
    cd (date +'%Y-%m-%d')
  end
end

function newSandbox -a type
 cd ~/Dev/_sandbox
 if test -e ~/Dev/_sandbox/(date +'%Y-%m-%d')
     cd (date +'%Y-%m-%d')
     touch script(math (count *."$type"))."$type"
     charm .
 else
     mkdir (date +'%Y-%m-%d')
     cd (date +'%Y-%m-%d')
     touch script0."$type"
     charm .
 end
end

function title_case -a string
  set -l matches (string match -r -a '\b[a-z]' $string)
  for match in $matches
    set -l upper (echo $match | tr a-z A-Z)
    set string (echo (string replace -r '\b[a-z]' $upper $string))
  end
  echo $string
end

function printFile -a file
  printf '%s\n' (less $file)
end

function writeTo -a file string
  echo > $file $string
end

function lsPen
  for dir in (find * -maxdepth 0 -type d);
     for file in (ls $dir);
         echo $file;
     end
   end
 end

#aliases------------------------------------------------------|
alias environ='charm ~/Dev/env_vars/.env'
alias confish='charm /Users/jakobbellamy/.config/fish/'
alias dev='cd ~/Dev/'
alias py=/usr/local/bin/python3
alias runserver='python manage.py runserver'
alias sqlmigrate='python manage.py sqlmigrate'
alias startapp='python manage.py startapp'
alias charm='open -a "Pycharm.app"'
alias storm='open -a "WebStorm.app"'
alias grip='open -a "DataGrip.app"'
alias icloud = 'cd ~/Library/Mobile Documents/com~apple~CloudDocs'
alias gc='git add . && git commit -m'
alias gp='git push'
alias gclear='git rm -r --cached .'
alias remignore='git rm -r --cached --force . && git add . && git commit -am "Remove ignored files"'
alias dbdir='cd ~/Users/jakobbellamy/Library/Application Support/JetBrains/DataGrip2020.1/consoles/db/3f40dab6-6f15-4503-87d9-2c410919f763'
