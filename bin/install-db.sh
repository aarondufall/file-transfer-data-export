#!/usr/bin/env bash

set -e

echo
echo "Installing Database"
echo "= = ="
echo

default_name=view_store

if [ -z ${DATABASE_USER+x} ]; then
  echo "(DATABASE_USER is not set. Default will be used.)"
  user=$default_name
else
  user=$DATABASE_USER
fi

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set. Default will be used.)"
  database=$default_name
else
  database=$DATABASE_NAME
fi

echo

function create-user {
  echo "Database user is: $user"

  user_exists=`psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$user'"`

  if [ "$user_exists" = "1" ]; then
    echo "Database user \"$user\" was previously created. Not creating again."
  else
    echo "Database user \"$user\" has not yet been created"
    echo "Creating database user \"$user\"..."
    createuser -s $user
  fi

  echo
}

function create-database {
  echo "Database name is: $database"
  echo "Creating database \"$database\"..."
  createdb $database
  echo
}

function script_dir {
  val="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$val"
}


function create-table {
  echo "Creating messages table..."
  base=$(script_dir)
  psql $database -f $base/table/files-table.sql
  echo
}


create-user
create-database
create-table
